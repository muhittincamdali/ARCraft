import Foundation
import simd

/// One frame of hand tracking: joint positions in a single coordinate space, and when they were
/// measured.
///
/// On visionOS, create it from a `HandAnchor` (world space, meters). On iOS and macOS, create it
/// from Vision's `HumanHandPoseObservation` (image space, pixels, `z == 0`). In tests and in the
/// simulator, where there is no hand tracking, create it with ``SyntheticHand``. The classifier
/// and the recognizer only compare distances, so the unit does not matter.
public struct HandPose: Sendable, Hashable {
    /// Which hand this is.
    public enum Chirality: String, Codable, Sendable, Hashable {
        case left
        case right
    }

    /// Which hand this is, or `nil` when the source does not say.
    public var chirality: Chirality?
    /// When the joints were measured, in seconds. Only differences between timestamps are used.
    public var timestamp: TimeInterval
    /// The tracked joints. A joint that is missing was not tracked in this frame.
    public private(set) var joints: [HandJoint: SIMD3<Float>]

    /// Creates a hand pose. Joints whose position contains NaN or infinity are dropped and count
    /// as untracked; a non-finite timestamp becomes `0`.
    public init(chirality: Chirality?, timestamp: TimeInterval, joints: [HandJoint: SIMD3<Float>]) {
        self.chirality = chirality
        self.timestamp = timestamp.isFinite ? timestamp : 0
        self.joints = joints.filter { $0.value.isFinite }
    }

    /// The position of `joint`, or `nil` when it was not tracked.
    public subscript(joint: HandJoint) -> SIMD3<Float>? {
        joints[joint]
    }

    /// Sets or clears the position of `joint`. A non-finite position clears it.
    public mutating func setPosition(_ position: SIMD3<Float>?, for joint: HandJoint) {
        joints[joint] = position.flatMap { $0.isFinite ? $0 : nil }
    }

    /// The distance between two joints, or `nil` when either was not tracked.
    public func distance(from first: HandJoint, to second: HandJoint) -> Float? {
        guard let a = joints[first], let b = joints[second] else { return nil }
        return simd_distance(a, b)
    }

    /// The same pose with every joint moved by `pose`, for example from hand space into world space.
    public func transformed(by pose: Pose) -> HandPose {
        HandPose(chirality: chirality, timestamp: timestamp, joints: joints.mapValues(pose.transform))
    }
}

extension HandPose: Codable {
    private enum CodingKeys: String, CodingKey {
        case chirality
        case timestamp
        case joints
    }

    /// Decodes `{"chirality": "right", "timestamp": 1.5, "joints": {"wrist": [x, y, z], …}}`.
    ///
    /// Unknown joint names are skipped so recordings from newer versions still load. A joint with
    /// the wrong number of coordinates, or with a coordinate that does not fit in a `Float`, makes
    /// decoding throw.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let chirality = try container.decodeIfPresent(Chirality.self, forKey: .chirality)
        let timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
        let rawJoints = try container.decode([String: [Float]].self, forKey: .joints)
        var joints: [HandJoint: SIMD3<Float>] = [:]
        for (name, coordinates) in rawJoints {
            guard let joint = HandJoint(rawValue: name) else { continue }
            guard coordinates.count == 3, coordinates.allSatisfy(\.isFinite) else {
                throw DecodingError.dataCorruptedError(forKey: .joints, in: container,
                                                       debugDescription: "Joint \(name) needs three finite coordinates.")
            }
            joints[joint] = SIMD3(coordinates[0], coordinates[1], coordinates[2])
        }
        self.init(chirality: chirality, timestamp: timestamp, joints: joints)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(chirality, forKey: .chirality)
        try container.encode(timestamp, forKey: .timestamp)
        let rawJoints = Dictionary(uniqueKeysWithValues: joints.map { ($0.key.rawValue, [$0.value.x, $0.value.y, $0.value.z]) })
        try container.encode(rawJoints, forKey: .joints)
    }
}
