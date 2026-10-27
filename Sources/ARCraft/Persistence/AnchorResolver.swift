import Foundation
import simd

/// Where an ``AnchoredItem`` is right now.
public enum ItemStatus: Sendable, Hashable {
    /// The anchor is tracked; show the item at this world pose.
    case placed(Pose)
    /// The anchor is known but not tracked at the moment; the pose is where it was last seen.
    /// Hide the item or show it dimmed.
    case anchorNotTracked(lastKnown: Pose)
    /// No anchor with the item's `anchorID` has been reported (yet).
    case anchorMissing
}

/// Keeps the latest state of each world anchor and tells you where each item belongs.
///
/// Feed it the anchor updates from ARKit (on visionOS, `apply(_:)` takes an
/// `AnchorUpdate<WorldAnchor>` directly), then ask for an item's ``ItemStatus``.
///
/// ```swift
/// for await update in worldTracking.anchorUpdates {
///     resolver.apply(update)
///     for item in items {
///         switch resolver.status(of: item) {
///         case .placed(let pose): show(item, at: pose)
///         case .anchorNotTracked, .anchorMissing: hide(item)
///         }
///     }
/// }
/// ```
public struct AnchorResolver: Sendable {
    /// The default for ``capacity``.
    public static let defaultCapacity = 4_096

    /// The known anchors by identifier.
    public private(set) var anchors: [UUID: WorldAnchorState] = [:]
    /// The most anchors kept. Updates for new anchors beyond it are refused.
    public let capacity: Int

    /// Creates an empty resolver. `capacity` is raised to at least 1.
    public init(capacity: Int = AnchorResolver.defaultCapacity) {
        self.capacity = max(capacity, 1)
    }

    /// Records an added or updated anchor. Returns `false`, and changes nothing, when the pose is
    /// not finite or the anchor is new and the resolver is full.
    @discardableResult
    public mutating func update(_ anchor: WorldAnchorState) -> Bool {
        guard anchor.pose.isFinite else { return false }
        guard anchors[anchor.id] != nil || anchors.count < capacity else { return false }
        anchors[anchor.id] = anchor
        return true
    }

    /// Forgets a removed anchor.
    public mutating func remove(anchorID: UUID) {
        anchors[anchorID] = nil
    }

    /// Where `item` is right now.
    public func status(of item: AnchoredItem) -> ItemStatus {
        guard let anchor = anchors[item.anchorID] else { return .anchorMissing }
        let pose = item.worldPose(anchorPose: anchor.pose)
        return anchor.isTracked ? .placed(pose) : .anchorNotTracked(lastKnown: pose)
    }

    /// The tracked anchor closest to `position` within `radius` meters, if any.
    ///
    /// Attach new items to an existing anchor when one is close: Apple recommends using few world
    /// anchors, and items on one anchor keep their arrangement exactly.
    public func nearestTrackedAnchor(to position: SIMD3<Float>, within radius: Float) -> WorldAnchorState? {
        guard position.isFinite, radius.isFinite, radius >= 0 else { return nil }
        return anchors.values
            .filter { $0.isTracked && simd_distance($0.pose.position, position) <= radius }
            .min { simd_distance($0.pose.position, position) < simd_distance($1.pose.position, position) }
    }

    /// Known anchors that no item in `items` uses. Remove them from ARKit to keep the count low.
    public func unusedAnchorIDs(given items: [AnchoredItem]) -> [UUID] {
        let used = Set(items.map(\.anchorID))
        return anchors.keys.filter { !used.contains($0) }.sorted { $0.uuidString < $1.uuidString }
    }
}
