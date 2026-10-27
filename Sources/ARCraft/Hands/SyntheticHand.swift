import Foundation
import simd

/// Builds plausible ``HandPose`` values from finger curl amounts.
///
/// Hand tracking does not run in the visionOS simulator, in Xcode previews or in unit tests. A
/// synthetic hand lets you drive the same recognizer code there: pick a preset, or blend between
/// two with ``interpolated(to:fraction:)`` to animate a pinch closing.
///
/// ```swift
/// let pinching = SyntheticHand.pinch.pose(chirality: .right, timestamp: 1.0)
/// let halfway = SyntheticHand.openPalm.interpolated(to: .pinch, fraction: 0.5).pose()
/// ```
///
/// The hand is built in its own space — wrist at the origin, fingers along +Y, palm facing +Z —
/// with the proportions of an adult hand, then scaled to `palmLength` and moved by `placedAt`.
public struct SyntheticHand: Sendable, Hashable {
    /// How far each finger is bent, from `0` (straight) to `1` (every joint bent 90°). For the
    /// thumb, `1` folds the tip over the middle finger.
    public var curl: [Finger: Float]
    /// How far the thumb tip has moved toward the index fingertip, from `0` to `1` (touching).
    public var pinch: Float

    /// Creates a hand. Missing fingers are straight; values are clamped to `0...1` and NaN counts as `0`.
    public init(curl: [Finger: Float] = [:], pinch: Float = 0) {
        self.curl = curl.mapValues(Self.unit)
        self.pinch = Self.unit(pinch)
    }

    /// All fingers straight and spread.
    public static let openPalm = SyntheticHand()
    /// All fingers curled, the thumb folded over them.
    public static let fist = SyntheticHand(curl: [.thumb: 1, .index: 1, .middle: 1, .ring: 1, .little: 1])
    /// The index finger straight, the others curled.
    public static let point = SyntheticHand(curl: [.thumb: 1, .middle: 1, .ring: 1, .little: 1])
    /// Thumb and index fingertips touching, the other fingers loosely bent.
    public static let pinch = SyntheticHand(curl: [.index: 0.4, .middle: 0.25, .ring: 0.3, .little: 0.35], pinch: 1)
    /// Every finger half bent: none of the recognized shapes.
    public static let relaxed = SyntheticHand(curl: [.thumb: 0.3, .index: 0.5, .middle: 0.5, .ring: 0.5, .little: 0.5])

    /// The preset for a recognized shape; `.other` gives ``relaxed``.
    public init(_ shape: HandShape) {
        switch shape {
        case .pinch: self = .pinch
        case .point: self = .point
        case .fist: self = .fist
        case .openPalm: self = .openPalm
        case .other: self = .relaxed
        }
    }

    /// A hand part of the way from this one to `other`; `fraction` is clamped to `0...1`.
    public func interpolated(to other: SyntheticHand, fraction: Float) -> SyntheticHand {
        let t = Self.unit(fraction)
        var blended: [Finger: Float] = [:]
        for finger in Finger.allCases {
            blended[finger] = (curl[finger] ?? 0) * (1 - t) + (other.curl[finger] ?? 0) * t
        }
        return SyntheticHand(curl: blended, pinch: pinch * (1 - t) + other.pinch * t)
    }

    /// The hand's joints as a ``HandPose``.
    ///
    /// - Parameters:
    ///   - chirality: A left hand is the right hand mirrored across the YZ plane.
    ///   - palmLength: Wrist to middle knuckle in the unit you want (meters by default). Non-positive
    ///     or non-finite values fall back to 0.09.
    ///   - placement: Moves the hand from its own space into the space you need.
    ///   - timestamp: The pose's timestamp.
    public func pose(chirality: HandPose.Chirality = .right, palmLength: Float = 0.09,
                     placedAt placement: Pose = .identity, timestamp: TimeInterval = 0) -> HandPose {
        let scale = palmLength.isFinite && palmLength > 0 ? palmLength : 0.09
        let mirror: SIMD3<Float> = chirality == .left ? SIMD3(-1, 1, 1) : SIMD3(1, 1, 1)
        let joints = unitJoints().mapValues { placement.transform($0 * mirror * scale) }
        return HandPose(chirality: chirality, timestamp: timestamp, joints: joints)
    }

    // MARK: - Geometry in palm-length units (right hand)

    private struct FingerModel {
        let knuckle: SIMD3<Float>
        let bones: (Float, Float, Float)
    }

    private static let palmNormal = SIMD3<Float>(0, 0, 1)

    private static let fingerModels: [Finger: FingerModel] = [
        .index: FingerModel(knuckle: SIMD3(0.28, 0.95, 0), bones: (0.45, 0.27, 0.2)),
        .middle: FingerModel(knuckle: SIMD3(0, 1, 0), bones: (0.5, 0.31, 0.22)),
        .ring: FingerModel(knuckle: SIMD3(-0.25, 0.95, 0), bones: (0.47, 0.3, 0.21)),
        .little: FingerModel(knuckle: SIMD3(-0.48, 0.85, 0), bones: (0.36, 0.22, 0.19))
    ]

    private func unitJoints() -> [HandJoint: SIMD3<Float>] {
        var joints: [HandJoint: SIMD3<Float>] = [
            .wrist: .zero,
            .forearmWrist: SIMD3(0, -0.3, 0),
            .forearmArm: SIMD3(0, -2.2, 0)
        ]
        let metacarpals: [Finger: HandJoint] = [.index: .indexFingerMetacarpal, .middle: .middleFingerMetacarpal,
                                                .ring: .ringFingerMetacarpal, .little: .littleFingerMetacarpal]
        for finger in Finger.fingers {
            guard let model = Self.fingerModels[finger], let metacarpal = metacarpals[finger] else { continue }
            joints[metacarpal] = model.knuckle * 0.3
            let chain = Self.bentChain(from: model, curl: curl[finger] ?? 0)
            for (joint, position) in zip(finger.joints, chain) {
                joints[joint] = position
            }
        }
        for (joint, position) in zip(Finger.thumb.joints, thumbChain(indexTip: joints[.indexFingerTip] ?? .zero,
                                                                     middleBase: joints[.middleFingerIntermediateBase] ?? .zero)) {
            joints[joint] = position
        }
        return joints
    }

    /// Knuckle, two intermediate joints and tip of a finger whose three joints each bend by `curl × 90°`.
    private static func bentChain(from model: FingerModel, curl: Float) -> [SIMD3<Float>] {
        let base = SpatialMath.normalized(SIMD3(model.knuckle.x * 0.3, 1, 0)) ?? SIMD3(0, 1, 0)
        let bend = curl * Float.pi / 2
        var points = [model.knuckle]
        var position = model.knuckle
        for (index, length) in [model.bones.0, model.bones.1, model.bones.2].enumerated() {
            let angle = bend * Float(index + 1)
            position += (base * cos(angle) + palmNormal * sin(angle)) * length
            points.append(position)
        }
        return points
    }

    /// Thumb knuckle to tip: open, folded over the middle finger, or reaching for the index tip.
    private func thumbChain(indexTip: SIMD3<Float>, middleBase: SIMD3<Float>) -> [SIMD3<Float>] {
        let knuckle = SIMD3<Float>(0.2, 0.15, 0.05)
        let direction = SpatialMath.normalized(SIMD3(1, 0.8, 0.3)) ?? SIMD3(1, 0, 0)
        let openTip = knuckle + direction * 0.88
        let foldedTip = middleBase + SIMD3(0.05, -0.15, 0.08)
        let curledTip = simd_mix(openTip, foldedTip, SIMD3(repeating: curl[.thumb] ?? 0))
        let tip = simd_mix(curledTip, indexTip, SIMD3(repeating: pinch))
        // Place the two intermediate joints along the knuckle-to-tip line, bowed away from the palm.
        let bow = -Self.palmNormal * 0.06
        let base = knuckle + (tip - knuckle) * 0.4 + bow
        let middle = knuckle + (tip - knuckle) * 0.72 + bow * 0.6
        return [knuckle, base, middle, tip]
    }

    private static func unit(_ value: Float) -> Float {
        value.isFinite ? min(max(value, 0), 1) : 0
    }
}
