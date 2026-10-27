#if canImport(RealityKit)
import RealityKit

@MainActor
extension Entity {
    /// Moves and turns the entity to `pose` without changing its scale.
    ///
    /// - Parameters:
    ///   - pose: The position and orientation to apply.
    ///   - reference: The entity whose space `pose` is in; `nil` means world space.
    public func setPose(_ pose: Pose, relativeTo reference: Entity? = nil) {
        setPosition(pose.position, relativeTo: reference)
        setOrientation(pose.orientation, relativeTo: reference)
    }

    /// The entity's pose in the space of `reference` (`nil` for world space), without scale.
    public func pose(relativeTo reference: Entity? = nil) -> Pose? {
        Pose(matrix: transformMatrix(relativeTo: reference))
    }

    /// The visual bounds of the entity and its descendants in its own space, before its own scale.
    /// `nil` when nothing visible is attached.
    public var localSpatialBounds: SpatialBounds? {
        let box = visualBounds(relativeTo: self)
        return SpatialBounds(min: box.min, max: box.max)
    }

    /// Scales the entity uniformly so its visual bounds fit `extents` (meters in the parent's
    /// space) and returns the scale it applied. Without `allowsUpscaling`, models that already
    /// fit keep their size. An entity with nothing visible keeps scale `1`.
    @discardableResult
    public func scaleToFit(_ extents: SIMD3<Float>, allowsUpscaling: Bool = false) -> Float {
        let factor = localSpatialBounds?.scaleToFit(extents, allowsUpscaling: allowsUpscaling) ?? 1
        scale = SIMD3(repeating: factor)
        return factor
    }
}
#endif
