import Foundation
import Testing
import simd
@testable import ARCraft

#if canImport(Vision)
import Vision

@Suite("Vision adapter")
struct VisionAdapterTests {
    @Test("All 21 Vision joints map to distinct ARCraft joints")
    func mapsEveryJoint() {
        let mapped = Set(HandJoint.visionJoints.values)
        #expect(HandJoint.visionJoints.count == 21)
        #expect(mapped.count == 21)
        for finger in Finger.allCases {
            #expect(finger.joints.allSatisfy(mapped.contains), "\(finger)")
        }
        #expect(mapped.contains(.wrist))
    }

    @Test("Anatomical names land on the matching ARKit-style joints")
    func anatomicalNames() {
        #expect(HandJoint(HumanHandPoseObservation.JointName.thumbCMC) == .thumbKnuckle)
        #expect(HandJoint(HumanHandPoseObservation.JointName.thumbIP) == .thumbIntermediateTip)
        #expect(HandJoint(HumanHandPoseObservation.JointName.indexMCP) == .indexFingerKnuckle)
        #expect(HandJoint(HumanHandPoseObservation.JointName.littleDIP) == .littleFingerIntermediateTip)
    }
}
#endif

#if os(visionOS) && canImport(ARKit)
import ARKit

@Suite("ARKit adapter")
struct ARKitAdapterTests {
    @Test("Every ARKit joint name maps to an ARCraft joint and back")
    func jointNamesRoundTrip() {
        #expect(HandSkeleton.JointName.allCases.count == HandJoint.allCases.count)
        for name in HandSkeleton.JointName.allCases {
            #expect(HandJoint(name)?.arkitName == name, "\(name)")
        }
    }

    @Test("A world anchor becomes a tracked anchor state at its transform")
    func worldAnchorState() throws {
        let pose = Pose(position: SIMD3(1, 0, -2), orientation: simd_quatf(angle: 0.5, axis: SIMD3(0, 1, 0)))
        let anchor = WorldAnchor(originFromAnchorTransform: pose.matrix)
        let state = try #require(WorldAnchorState(anchor))
        #expect(state.id == anchor.id)
        #expect(state.pose.isApproximatelyEqual(to: pose))
    }
}
#endif
