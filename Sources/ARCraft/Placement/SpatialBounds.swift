import simd

/// An axis-aligned box, used to fit models of unknown size into a volume or onto a table.
///
/// USDZ files arrive in centimeters, meters or anything in between, and centered anywhere. Read a
/// model's bounds, then use ``scaleToFit(_:allowsUpscaling:)`` and
/// ``restingOffset(scale:)`` to make it fit a window, a volume or the palm of a hand.
public struct SpatialBounds: Sendable, Hashable {
    /// The corner with the smallest coordinates.
    public let min: SIMD3<Float>
    /// The corner with the largest coordinates.
    public let max: SIMD3<Float>

    /// Creates bounds. `nil` when a coordinate is not finite or `min` exceeds `max` on any axis
    /// (RealityKit reports an empty box that way).
    public init?(min: SIMD3<Float>, max: SIMD3<Float>) {
        guard min.isFinite, max.isFinite, all(min .<= max) else { return nil }
        self.min = min
        self.max = max
    }

    /// The smallest box containing every finite point. `nil` when there is none.
    public init?(points: some Sequence<SIMD3<Float>>) {
        var lower: SIMD3<Float>?
        var upper: SIMD3<Float>?
        for point in points where point.isFinite {
            lower = lower.map { simd_min($0, point) } ?? point
            upper = upper.map { simd_max($0, point) } ?? point
        }
        guard let lower, let upper else { return nil }
        self.init(min: lower, max: upper)
    }

    /// The size along each axis.
    public var extents: SIMD3<Float> { max - min }

    /// The midpoint. Computed as `min / 2 + max / 2` so it cannot overflow near `Float`'s limit.
    public var center: SIMD3<Float> { min / 2 + max / 2 }

    /// The uniform scale that makes the box fit inside `target` (a size along each axis).
    ///
    /// Axes where the box is flat, or where `target` is zero, negative or not finite, do not
    /// constrain the result; when no axis does, the result is `1`. Without `allowsUpscaling` the
    /// result never exceeds `1`, so small models are not blown up.
    public func scaleToFit(_ target: SIMD3<Float>, allowsUpscaling: Bool = false) -> Float {
        var scale = Float.infinity
        for axis in 0..<3 {
            // Half sizes, so a box spanning nearly all of Float's range does not overflow to infinity.
            let halfSize = max[axis] / 2 - min[axis] / 2
            let limit = target[axis]
            guard halfSize > SpatialMath.epsilon / 2, limit.isFinite, limit > 0 else { continue }
            scale = Swift.min(scale, (limit / 2) / halfSize)
        }
        guard scale.isFinite, scale > 0 else { return 1 }
        return allowsUpscaling ? scale : Swift.min(scale, 1)
    }

    /// The translation that, after scaling by `scale`, puts the bottom center of the box at the
    /// origin, so the model rests on whatever its parent stands on.
    public func restingOffset(scale: Float = 1) -> SIMD3<Float> {
        let factor = scale.isFinite ? scale : 1
        return -SIMD3(center.x, min.y, center.z) * factor
    }
}
