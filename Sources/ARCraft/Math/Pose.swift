import simd

/// A rigid transform: a position and an orientation, without scale.
///
/// ARKit and RealityKit hand out `simd_float4x4` matrices. `Pose` is the value ARCraft stores,
/// filters and persists instead: it cannot carry scale or shear, it is `Codable`, and both
/// ``init(matrix:)`` and decoding reject NaN and infinite values, so a corrupt matrix or file
/// never reaches your scene.
///
/// ```swift
/// let anchorPose = Pose(matrix: worldAnchor.originFromAnchorTransform)
/// let itemPose = anchorPose.map { $0 * item.offset }
/// ```
public struct Pose: Sendable {
    /// The position in meters.
    public var position: SIMD3<Float>
    /// The orientation as a unit quaternion.
    public var orientation: simd_quatf

    /// The pose at the origin with no rotation.
    public static let identity = Pose()

    /// Creates a pose. The orientation is normalized; a zero quaternion becomes the identity.
    public init(position: SIMD3<Float> = .zero, orientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)) {
        self.position = position
        self.orientation = Pose.unitOrientation(orientation) ?? simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    }

    /// Creates a pose from a transform matrix such as `originFromAnchorTransform`.
    ///
    /// Scale is removed from the rotation columns. Returns `nil` when the matrix contains a
    /// non-finite value, has a zero-length axis or mirrors space (negative determinant).
    public init?(matrix: simd_float4x4) {
        let translation = SIMD3(matrix.columns.3.x, matrix.columns.3.y, matrix.columns.3.z)
        let axes = [matrix.columns.0, matrix.columns.1, matrix.columns.2].map { SIMD3($0.x, $0.y, $0.z) }
        guard translation.isFinite else { return nil }
        let units = axes.compactMap(SpatialMath.normalized)
        guard units.count == 3 else { return nil }
        let rotation = simd_float3x3(columns: (units[0], units[1], units[2]))
        guard simd_determinant(rotation) > 0.5 else { return nil }
        self.init(position: translation, orientation: simd_quatf(rotation))
    }

    /// The pose as a 4×4 transform matrix.
    public var matrix: simd_float4x4 {
        var result = simd_float4x4(orientation)
        result.columns.3 = SIMD4(position, 1)
        return result
    }

    /// `true` when the position and orientation contain only finite numbers.
    public var isFinite: Bool {
        position.isFinite && orientation.vector.x.isFinite && orientation.vector.y.isFinite
            && orientation.vector.z.isFinite && orientation.vector.w.isFinite
    }

    /// The pose that undoes this one.
    public var inverse: Pose {
        let inverseOrientation = orientation.inverse
        return Pose(position: inverseOrientation.act(-position), orientation: inverseOrientation)
    }

    /// Moves a point from this pose's local space into the parent space.
    public func transform(_ point: SIMD3<Float>) -> SIMD3<Float> {
        orientation.act(point) + position
    }

    /// Rotates a direction from this pose's local space into the parent space.
    public func rotate(_ direction: SIMD3<Float>) -> SIMD3<Float> {
        orientation.act(direction)
    }

    /// This pose expressed in the space of `base`: `base.inverse * self`.
    public func relative(to base: Pose) -> Pose {
        base.inverse * self
    }

    /// Composes two poses: the result applies `rhs` first, then `lhs`.
    ///
    /// `anchorPose * offset` turns an offset stored relative to an anchor into a world pose.
    public static func * (lhs: Pose, rhs: Pose) -> Pose {
        Pose(position: lhs.transform(rhs.position), orientation: lhs.orientation * rhs.orientation)
    }

    static func unitOrientation(_ quaternion: simd_quatf) -> simd_quatf? {
        let vector = quaternion.vector
        guard vector.x.isFinite, vector.y.isFinite, vector.z.isFinite, vector.w.isFinite else { return nil }
        let length = simd_length(vector)
        guard length.isFinite, length > SpatialMath.epsilon else { return nil }
        return simd_quatf(vector: vector / length)
    }
}

extension Pose: Equatable, Hashable {
    public static func == (lhs: Pose, rhs: Pose) -> Bool {
        lhs.position == rhs.position && lhs.orientation.vector == rhs.orientation.vector
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(orientation.vector)
    }

    /// `true` when both poses are within `positionTolerance` meters and `angleTolerance` radians.
    public func isApproximatelyEqual(to other: Pose, positionTolerance: Float = 1e-4, angleTolerance: Float = 1e-3) -> Bool {
        simd_distance(position, other.position) <= positionTolerance
            && SpatialMath.angle(between: orientation, and: other.orientation) <= angleTolerance
    }
}

extension Pose: Codable {
    private enum CodingKeys: String, CodingKey {
        case position
        case orientation
    }

    /// Decodes `{"position": [x, y, z], "orientation": [x, y, z, w]}`.
    /// Throws for non-finite numbers, wrong array lengths and a zero-length quaternion.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let position = try container.decode([Float].self, forKey: .position)
        let orientation = try container.decode([Float].self, forKey: .orientation)
        guard position.count == 3, position.allSatisfy(\.isFinite) else {
            throw DecodingError.dataCorruptedError(forKey: .position, in: container,
                                                   debugDescription: "Expected three finite numbers.")
        }
        guard orientation.count == 4,
              let unit = Pose.unitOrientation(simd_quatf(vector: SIMD4(orientation[0], orientation[1], orientation[2], orientation[3])))
        else {
            throw DecodingError.dataCorruptedError(forKey: .orientation, in: container,
                                                   debugDescription: "Expected a non-zero quaternion of four finite numbers.")
        }
        self.init(position: SIMD3(position[0], position[1], position[2]), orientation: unit)
    }

    public func encode(to encoder: any Encoder) throws {
        guard isFinite else {
            throw EncodingError.invalidValue(self, .init(codingPath: encoder.codingPath,
                                                         debugDescription: "A pose with non-finite values cannot be encoded."))
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode([position.x, position.y, position.z], forKey: .position)
        let vector = orientation.vector
        try container.encode([vector.x, vector.y, vector.z, vector.w], forKey: .orientation)
    }
}
