import Foundation

/// Why ``PlacementStore`` could not locate its file.
public enum PlacementStoreError: Error, Sendable, Hashable {
    /// The file name is empty, too long, hidden or contains a path separator.
    case invalidFileName(String)
}

/// Saves and loads ``AnchoredItem`` lists in a JSON file, one call at a time.
///
/// Reads never load more than ``PlacementArchive/Limits/maxBytes`` bytes, even if the file grows
/// while it is read. Writes are atomic, so a crash mid-write leaves the previous file intact. On
/// iOS and visionOS the file is protected until the device is first unlocked after a restart.
///
/// ```swift
/// let store = try PlacementStore(fileURL: PlacementStore.applicationSupportFile(named: "room.json"))
/// let contents = try await store.load()
/// try await store.save(contents.items + [newItem])
/// ```
public actor PlacementStore {
    /// Where the archive lives.
    public nonisolated let fileURL: URL
    /// The codec and limits used for reading and writing.
    public nonisolated let archive: PlacementArchive

    /// Creates a store for `fileURL`. Nothing is read or written until you call a method.
    public init(fileURL: URL, archive: PlacementArchive = PlacementArchive()) {
        self.fileURL = fileURL
        self.archive = archive
    }

    /// A file in the app's Application Support directory, inside an `ARCraft` folder.
    ///
    /// `name` must be a plain file name: not empty, at most 255 bytes, not starting with a dot and
    /// without `/` or `:`. This keeps a name built from user input from escaping the folder.
    public static func applicationSupportFile(named name: String) throws -> URL {
        guard !name.isEmpty, name.utf8.count <= 255, !name.hasPrefix("."),
              !name.contains("/"), !name.contains(":"), !name.contains("\0") else {
            throw PlacementStoreError.invalidFileName(name)
        }
        let directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                                    appropriateFor: nil, create: true)
        return directory.appendingPathComponent("ARCraft", isDirectory: true).appendingPathComponent(name, isDirectory: false)
    }

    /// Reads the archive. A missing file gives an empty list.
    ///
    /// - Throws: ``PlacementArchiveError`` for a file that is too large or not a valid archive,
    ///   or the file system's error when the file exists but cannot be read.
    public func load() throws -> PlacementArchive.Contents {
        let handle: FileHandle
        do {
            handle = try FileHandle(forReadingFrom: fileURL)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return PlacementArchive.Contents(items: [], rejectedCount: 0)
        }
        defer { try? handle.close() }
        let limit = archive.limits.maxBytes
        let data = try handle.read(upToCount: limit + 1) ?? Data()
        guard data.count <= limit else { throw PlacementArchiveError.tooLarge(byteCount: data.count, limit: limit) }
        return try archive.decode(data)
    }

    /// Replaces the archive with `items`.
    ///
    /// - Throws: ``PlacementArchiveError`` when an item is invalid or the archive would exceed
    ///   the limits (the file is left unchanged), or the file system's error.
    public func save(_ items: [AnchoredItem]) throws {
        let data = try archive.encode(items)
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL, options: Self.writingOptions)
    }

    /// Deletes the archive. Deleting a missing file is not an error.
    public func removeAll() throws {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error as CocoaError where error.code == .fileNoSuchFile {
            return
        }
    }

    private static var writingOptions: Data.WritingOptions {
        #if os(iOS) || os(visionOS)
        [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        #else
        [.atomic]
        #endif
    }
}
