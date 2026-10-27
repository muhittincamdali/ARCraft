#if os(visionOS) && canImport(ARKit)
import ARKit
import Foundation
import simd

extension HandJoint {
    /// The ARKit joint with the same name, or `nil` for a joint ARCraft does not know yet.
    public init?(_ name: HandSkeleton.JointName) {
        guard let joint = HandJoint.allCases.first(where: { $0.arkitName == name }) else { return nil }
        self = joint
    }

    /// The ARKit joint with the same name.
    public var arkitName: HandSkeleton.JointName {
        switch self {
        case .wrist: .wrist
        case .thumbKnuckle: .thumbKnuckle
        case .thumbIntermediateBase: .thumbIntermediateBase
        case .thumbIntermediateTip: .thumbIntermediateTip
        case .thumbTip: .thumbTip
        case .indexFingerMetacarpal: .indexFingerMetacarpal
        case .indexFingerKnuckle: .indexFingerKnuckle
        case .indexFingerIntermediateBase: .indexFingerIntermediateBase
        case .indexFingerIntermediateTip: .indexFingerIntermediateTip
        case .indexFingerTip: .indexFingerTip
        case .middleFingerMetacarpal: .middleFingerMetacarpal
        case .middleFingerKnuckle: .middleFingerKnuckle
        case .middleFingerIntermediateBase: .middleFingerIntermediateBase
        case .middleFingerIntermediateTip: .middleFingerIntermediateTip
        case .middleFingerTip: .middleFingerTip
        case .ringFingerMetacarpal: .ringFingerMetacarpal
        case .ringFingerKnuckle: .ringFingerKnuckle
        case .ringFingerIntermediateBase: .ringFingerIntermediateBase
        case .ringFingerIntermediateTip: .ringFingerIntermediateTip
        case .ringFingerTip: .ringFingerTip
        case .littleFingerMetacarpal: .littleFingerMetacarpal
        case .littleFingerKnuckle: .littleFingerKnuckle
        case .littleFingerIntermediateBase: .littleFingerIntermediateBase
        case .littleFingerIntermediateTip: .littleFingerIntermediateTip
        case .littleFingerTip: .littleFingerTip
        case .forearmWrist: .forearmWrist
        case .forearmArm: .forearmArm
        }
    }
}

extension HandPose {
    /// The tracked joints of a hand anchor, in world space (meters).
    ///
    /// Returns `nil` when the anchor is not tracked or has no skeleton. Joints that ARKit marks as
    /// not tracked are left out.
    ///
    /// ```swift
    /// for await update in handTracking.anchorUpdates {
    ///     guard let pose = HandPose(update.anchor, timestamp: update.timestamp) else {
    ///         _ = pinch.trackingLost(at: update.timestamp)
    ///         continue
    ///     }
    ///     for event in pinch.update(with: pose) { handle(event) }
    /// }
    /// ```
    public init?(_ anchor: HandAnchor, timestamp: TimeInterval) {
        guard anchor.isTracked, let skeleton = anchor.handSkeleton else { return nil }
        let originFromAnchor = anchor.originFromAnchorTransform
        var joints: [HandJoint: SIMD3<Float>] = [:]
        for joint in HandJoint.allCases {
            let skeletonJoint = skeleton.joint(joint.arkitName)
            guard skeletonJoint.isTracked else { continue }
            let world = originFromAnchor * skeletonJoint.anchorFromJointTransform
            joints[joint] = SIMD3(world.columns.3.x, world.columns.3.y, world.columns.3.z)
        }
        let chirality: Chirality = anchor.chirality == .left ? .left : .right
        self.init(chirality: chirality, timestamp: timestamp, joints: joints)
    }
}

extension WorldAnchorState {
    /// The state of an ARKit world anchor. `nil` when its transform is not a valid rigid transform.
    public init?(_ anchor: WorldAnchor) {
        guard let pose = Pose(matrix: anchor.originFromAnchorTransform) else { return nil }
        self.init(id: anchor.id, pose: pose, isTracked: anchor.isTracked)
    }
}

extension AnchorResolver {
    /// Applies an update from `WorldTrackingProvider.anchorUpdates`. Returns `false` when the
    /// update was refused (invalid transform or capacity reached).
    @discardableResult
    public mutating func apply(_ update: AnchorUpdate<WorldAnchor>) -> Bool {
        switch update.event {
        case .added, .updated:
            guard let state = WorldAnchorState(update.anchor) else { return false }
            return self.update(state)
        case .removed:
            remove(anchorID: update.anchor.id)
            return true
        }
    }
}
#endif
