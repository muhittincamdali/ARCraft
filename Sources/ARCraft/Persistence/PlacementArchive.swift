import Foundation

/// Why a placement archive could not be written or read.
public enum PlacementArchiveError: Error, Sendable, Hashable {
    /// The data is larger than ``PlacementArchive/Limits/maxBytes``.
    case tooLarge(byteCount: Int, limit: Int)
    /// There are more items than ``PlacementArchive/Limits/maxItems``.
    case tooManyItems(count: Int, limit: Int)
    /// The archive was written by a newer, incompatible version.
    case unsupportedVersion(Int)
    /// The data is not a placement archive.
    case malformed
    /// An item breaks a limit or has a non-finite offset, so it would not survive a round trip.
    case invalidItem(id: UUID)
    /// Two items share an identifier.
    case duplicateItem(id: UUID)
}

/// Encodes and decodes ``AnchoredItem`` lists as versioned JSON, within fixed size limits.
///
/// The archive is a file your app reads at launch, so it is treated as untrusted input: the size
/// is checked before parsing, every item is validated, and one damaged item does not lose the
/// others. Writing is strict: an item that could not be read back throws instead of being saved.
///
/// ```json
/// {"version": 1, "items": [{"id": "…", "anchorID": "…", "kind": "lamp",
///   "offset": {"position": [0, 0, 0], "orientation": [0, 0, 0, 1]}, "attributes": {}}]}
/// ```
public struct PlacementArchive: Sendable, Hashable {
    /// The format version this build writes and reads.
    public static let currentVersion = 1

    /// Upper bounds that keep a damaged or hostile file from exhausting memory.
    public struct Limits: Sendable, Hashable {
        /// The largest archive, in bytes.
        public let maxBytes: Int
        /// The most items in one archive.
        public let maxItems: Int
        /// The longest `kind`, in UTF-8 bytes.
        public let maxKindLength: Int
        /// The most attributes per item.
        public let maxAttributes: Int
        /// The longest attribute key or value, in UTF-8 bytes.
        public let maxAttributeLength: Int

        /// The largest value ``maxBytes`` accepts: 256 MiB.
        public static let maxBytesCeiling = 268_435_456

        /// Creates limits. Values below 1 are raised to 1, and `maxBytes` is capped at
        /// ``maxBytesCeiling``.
        public init(maxBytes: Int = 1_048_576, maxItems: Int = 1_000, maxKindLength: Int = 128,
                    maxAttributes: Int = 16, maxAttributeLength: Int = 1_024) {
            self.maxBytes = min(max(maxBytes, 1), Self.maxBytesCeiling)
            self.maxItems = max(maxItems, 1)
            self.maxKindLength = max(maxKindLength, 1)
            self.maxAttributes = max(maxAttributes, 1)
            self.maxAttributeLength = max(maxAttributeLength, 1)
        }
    }

    /// The items read from an archive, and how many were skipped.
    public struct Contents: Sendable, Hashable {
        /// The valid items, in file order.
        public var items: [AnchoredItem]
        /// Items that were damaged, broke a limit or repeated an earlier identifier.
        public var rejectedCount: Int
    }

    /// The limits in use.
    public var limits: Limits

    /// Creates an archive codec.
    public init(limits: Limits = Limits()) {
        self.limits = limits
    }

    /// `true` when `item` fits the limits and has a finite offset.
    public func isValid(_ item: AnchoredItem) -> Bool {
        let kindLength = item.kind.utf8.count
        guard kindLength > 0, kindLength <= limits.maxKindLength, item.offset.isFinite,
              item.attributes.count <= limits.maxAttributes else { return false }
        return item.attributes.allSatisfy { key, value in
            !key.isEmpty && key.utf8.count <= limits.maxAttributeLength && value.utf8.count <= limits.maxAttributeLength
        }
    }

    /// Encodes `items`. Throws for an invalid or duplicate item, too many items or too many bytes.
    public func encode(_ items: [AnchoredItem]) throws(PlacementArchiveError) -> Data {
        guard items.count <= limits.maxItems else { throw .tooManyItems(count: items.count, limit: limits.maxItems) }
        var seen = Set<UUID>()
        for item in items {
            guard isValid(item) else { throw .invalidItem(id: item.id) }
            guard seen.insert(item.id).inserted else { throw .duplicateItem(id: item.id) }
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(Envelope(version: Self.currentVersion, items: items)) else { throw .malformed }
        guard data.count <= limits.maxBytes else { throw .tooLarge(byteCount: data.count, limit: limits.maxBytes) }
        return data
    }

    /// Decodes an archive, keeping every valid item and counting the rest.
    ///
    /// Throws when the data is too large, is not an archive, comes from a newer version or holds
    /// more items than allowed. Damaged items, items over a limit and repeated identifiers are
    /// skipped and counted in ``Contents/rejectedCount``.
    public func decode(_ data: Data) throws(PlacementArchiveError) -> Contents {
        guard data.count <= limits.maxBytes else { throw .tooLarge(byteCount: data.count, limit: limits.maxBytes) }
        let decoder = JSONDecoder()
        guard let header = try? decoder.decode(Header.self, from: data) else { throw .malformed }
        guard header.version == Self.currentVersion else { throw .unsupportedVersion(header.version) }
        guard let body = try? decoder.decode(LenientBody.self, from: data) else { throw .malformed }
        guard body.items.count <= limits.maxItems else { throw .tooManyItems(count: body.items.count, limit: limits.maxItems) }
        var items: [AnchoredItem] = []
        var seen = Set<UUID>()
        for case let item? in body.items.map(\.item) where isValid(item) && seen.insert(item.id).inserted {
            items.append(item)
        }
        return Contents(items: items, rejectedCount: body.items.count - items.count)
    }

    private struct Envelope: Encodable {
        let version: Int
        let items: [AnchoredItem]
    }

    private struct Header: Decodable {
        let version: Int
    }

    private struct LenientBody: Decodable {
        let items: [LenientItem]
    }

    /// Decodes one item, turning any failure into `nil` so the rest of the array still decodes.
    private struct LenientItem: Decodable {
        let item: AnchoredItem?

        init(from decoder: any Decoder) throws {
            item = try? AnchoredItem(from: decoder)
        }
    }
}
