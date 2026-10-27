#if canImport(Vision)
import CoreGraphics
import Foundation
import Vision

extension HandJoint {
    /// The ARCraft joint for a joint of Vision's 2D hand pose.
    ///
    /// Vision names joints anatomically (CMC, MP, IP for the thumb; MCP, PIP, DIP for the fingers)
    /// and has no metacarpal or forearm joints.
    public init?(_ name: HumanHandPoseObservation.JointName) {
        guard let joint = Self.visionJoints[name] else { return nil }
        self = joint
    }

    static let visionJoints: [HumanHandPoseObservation.JointName: HandJoint] = [
        .wrist: .wrist,
        .thumbCMC: .thumbKnuckle, .thumbMP: .thumbIntermediateBase, .thumbIP: .thumbIntermediateTip, .thumbTip: .thumbTip,
        .indexMCP: .indexFingerKnuckle, .indexPIP: .indexFingerIntermediateBase,
        .indexDIP: .indexFingerIntermediateTip, .indexTip: .indexFingerTip,
        .middleMCP: .middleFingerKnuckle, .middlePIP: .middleFingerIntermediateBase,
        .middleDIP: .middleFingerIntermediateTip, .middleTip: .middleFingerTip,
        .ringMCP: .ringFingerKnuckle, .ringPIP: .ringFingerIntermediateBase,
        .ringDIP: .ringFingerIntermediateTip, .ringTip: .ringFingerTip,
        .littleMCP: .littleFingerKnuckle, .littlePIP: .littleFingerIntermediateBase,
        .littleDIP: .littleFingerIntermediateTip, .littleTip: .littleFingerTip
    ]
}

extension HandPose {
    /// The joints of a Vision hand observation in image pixels, with `z == 0`.
    ///
    /// Vision's coordinates are normalized separately on each axis; multiplying by the image size
    /// makes distances comparable in every direction, which the classifier relies on. Joints below
    /// `minimumConfidence` are left out.
    ///
    /// - Returns: `nil` when `imageSize` is not a positive, finite size.
    public init?(_ observation: HumanHandPoseObservation, imageSize: CGSize, timestamp: TimeInterval,
                 minimumConfidence: Float = 0.3) {
        guard imageSize.width.isFinite, imageSize.height.isFinite, imageSize.width > 0, imageSize.height > 0 else {
            return nil
        }
        var joints: [HandJoint: SIMD3<Float>] = [:]
        for (name, joint) in HandJoint.visionJoints {
            guard let point = observation.joint(for: name), point.confidence >= minimumConfidence else { continue }
            joints[joint] = SIMD3(Float(point.location.x * imageSize.width), Float(point.location.y * imageSize.height), 0)
        }
        let chirality: Chirality? = observation.chirality.map { $0 == .left ? .left : .right }
        self.init(chirality: chirality, timestamp: timestamp, joints: joints)
    }
}
#endif
