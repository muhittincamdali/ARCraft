/// A joint of the hand skeleton. The names and the set of joints match ARKit's
/// `HandSkeleton.JointName` on visionOS; Vision's 2D hand pose maps onto a subset of them.
public enum HandJoint: String, CaseIterable, Codable, Sendable, Hashable {
    case wrist
    case thumbKnuckle
    case thumbIntermediateBase
    case thumbIntermediateTip
    case thumbTip
    case indexFingerMetacarpal
    case indexFingerKnuckle
    case indexFingerIntermediateBase
    case indexFingerIntermediateTip
    case indexFingerTip
    case middleFingerMetacarpal
    case middleFingerKnuckle
    case middleFingerIntermediateBase
    case middleFingerIntermediateTip
    case middleFingerTip
    case ringFingerMetacarpal
    case ringFingerKnuckle
    case ringFingerIntermediateBase
    case ringFingerIntermediateTip
    case ringFingerTip
    case littleFingerMetacarpal
    case littleFingerKnuckle
    case littleFingerIntermediateBase
    case littleFingerIntermediateTip
    case littleFingerTip
    case forearmWrist
    case forearmArm
}

/// A finger of the hand.
public enum Finger: String, CaseIterable, Codable, Sendable, Hashable {
    case thumb
    case index
    case middle
    case ring
    case little

    /// The four fingers other than the thumb.
    public static let fingers: [Finger] = [.index, .middle, .ring, .little]

    /// The finger's joints from the knuckle at the palm to the tip.
    public var joints: [HandJoint] {
        switch self {
        case .thumb: [.thumbKnuckle, .thumbIntermediateBase, .thumbIntermediateTip, .thumbTip]
        case .index: [.indexFingerKnuckle, .indexFingerIntermediateBase, .indexFingerIntermediateTip, .indexFingerTip]
        case .middle: [.middleFingerKnuckle, .middleFingerIntermediateBase, .middleFingerIntermediateTip, .middleFingerTip]
        case .ring: [.ringFingerKnuckle, .ringFingerIntermediateBase, .ringFingerIntermediateTip, .ringFingerTip]
        case .little: [.littleFingerKnuckle, .littleFingerIntermediateBase, .littleFingerIntermediateTip, .littleFingerTip]
        }
    }

    /// The joint where the finger meets the palm.
    public var knuckle: HandJoint { joints[0] }

    /// The fingertip.
    public var tip: HandJoint { joints[3] }
}
