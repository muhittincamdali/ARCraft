import Foundation
import simd

/// A piece of content placed in the room, stored relative to a world anchor.
///
/// ARKit persists world anchors across launches on visionOS, but not what your app put there.
/// `AnchoredItem` is that missing record: which anchor, what kind of content, where relative to
/// the anchor, and a few string attributes. Several items can share one anchor, which keeps the
/// number of anchors (and the work ARKit does to relocalize them) low.
public struct AnchoredItem: Sendable, Hashable, Codable, Identifiable {
    /// The item's own identifier.
    public var id: UUID
    /// The identifier of the world anchor the item is attached to.
    public var anchorID: UUID
    /// What to show, for example the name of an entity in your Reality Composer Pro scene.
    public var kind: String
    /// The item's pose in the anchor's space.
    public var offset: Pose
    /// Small app-defined values, such as a color or a note's text.
    public var attributes: [String: String]

    /// Creates an item from its offset to the anchor.
    public init(id: UUID = UUID(), anchorID: UUID, kind: String, offset: Pose = .identity, attributes: [String: String] = [:]) {
        self.id = id
        self.anchorID = anchorID
        self.kind = kind
        self.offset = offset
        self.attributes = attributes
    }

    /// Creates an item at `worldPose`, attached to `anchor`, computing the offset for you.
    public init(id: UUID = UUID(), kind: String, worldPose: Pose, anchor: WorldAnchorState, attributes: [String: String] = [:]) {
        self.init(id: id, anchorID: anchor.id, kind: kind, offset: worldPose.relative(to: anchor.pose), attributes: attributes)
    }

    /// The item's world pose when its anchor is at `anchorPose`.
    ///
    /// The result is not finite when the composition overflows `Float`, for example for an offset
    /// near `Float.greatestFiniteMagnitude`. ``AnchorResolver/status(of:)`` checks this for you.
    public func worldPose(anchorPose: Pose) -> Pose {
        anchorPose * offset
    }
}

/// What ARCraft knows about one world anchor: where it is and whether ARKit is tracking it.
public struct WorldAnchorState: Sendable, Hashable, Identifiable {
    /// The anchor's identifier (`WorldAnchor.id`).
    public var id: UUID
    /// The anchor's world pose.
    public var pose: Pose
    /// `false` while ARKit cannot currently locate the anchor, for example in another room.
    public var isTracked: Bool

    /// Creates an anchor state.
    public init(id: UUID, pose: Pose, isTracked: Bool = true) {
        self.id = id
        self.pose = pose
        self.isTracked = isTracked
    }
}
