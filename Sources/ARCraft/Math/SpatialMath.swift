import simd

extension SIMD3 where Scalar == Float {
    /// `true` when every component is a finite number (not NaN and not infinite).
    public var isFinite: Bool {
        x.isFinite && y.isFinite && z.isFinite
    }
}

/// Small vector helpers shared by the filters, the hand classifier and the placement solver.
enum SpatialMath {
    /// Lengths at or below this value are treated as zero.
    static let epsilon: Float = 1e-6

    /// The world's up axis in RealityKit and ARKit (+Y).
    static let worldUp = SIMD3<Float>(0, 1, 0)

    /// The unit vector along `vector`, or `nil` when it is zero, NaN or infinite.
    static func normalized(_ vector: SIMD3<Float>) -> SIMD3<Float>? {
        guard vector.isFinite else { return nil }
        let length = simd_length(vector)
        guard length.isFinite, length > epsilon else { return nil }
        return vector / length
    }

    /// `vector` with its component along `axis` removed. `axis` must be a unit vector.
    static func projected(_ vector: SIMD3<Float>, ontoPlaneWithNormal axis: SIMD3<Float>) -> SIMD3<Float> {
        vector - simd_dot(vector, axis) * axis
    }

    /// The rotation whose +Z axis points along `forward` and whose +Y axis is as close to `up`
    /// as the forward direction allows. `nil` when the two directions are parallel or invalid.
    static func lookRotation(forward: SIMD3<Float>, up: SIMD3<Float>) -> simd_quatf? {
        guard let forwardAxis = normalized(forward),
              let rightAxis = normalized(simd_cross(up, forwardAxis)) else { return nil }
        let upAxis = simd_cross(forwardAxis, rightAxis)
        return simd_quatf(simd_float3x3(columns: (rightAxis, upAxis, forwardAxis)))
    }

    /// The angle between two directions in radians, in `0...π`. `nil` for zero or invalid input.
    static func angle(between first: SIMD3<Float>, and second: SIMD3<Float>) -> Float? {
        guard let a = normalized(first), let b = normalized(second) else { return nil }
        return acos(min(max(simd_dot(a, b), -1), 1))
    }

    /// The angle between two orientations in radians, in `0...π`.
    static func angle(between first: simd_quatf, and second: simd_quatf) -> Float {
        let dot = abs(simd_dot(first.vector, second.vector))
        return 2 * acos(min(dot, 1))
    }
}
