import Foundation
import Testing
import simd
@testable import ARCraft

/// Hand poses typed in by hand (meters, right hand, palm facing +Z), independent of SyntheticHand.
enum HandFixtures {
    static let palm: [HandJoint: SIMD3<Float>] = [
        .wrist: SIMD3(0, 0, 0),
        .indexFingerKnuckle: SIMD3(0.025, 0.086, 0),
        .middleFingerKnuckle: SIMD3(0, 0.09, 0),
        .ringFingerKnuckle: SIMD3(-0.022, 0.085, 0),
        .littleFingerKnuckle: SIMD3(-0.042, 0.076, 0),
        .thumbKnuckle: SIMD3(0.02, 0.015, 0.005)
    ]

    static let openHand = HandPose(chirality: .right, timestamp: 0, joints: palm.merging([
        .thumbTip: SIMD3(0.085, 0.07, 0.02),
        .indexFingerTip: SIMD3(0.034, 0.168, 0),
        .middleFingerTip: SIMD3(0, 0.178, 0),
        .ringFingerTip: SIMD3(-0.03, 0.165, 0),
        .littleFingerTip: SIMD3(-0.058, 0.138, 0)
    ]) { $1 })

    static let fist = HandPose(chirality: .right, timestamp: 0, joints: palm.merging([
        .thumbTip: SIMD3(0.006, 0.072, 0.04),
        .indexFingerTip: SIMD3(0.024, 0.062, 0.025),
        .middleFingerTip: SIMD3(0, 0.064, 0.026),
        .ringFingerTip: SIMD3(-0.02, 0.06, 0.024),
        .littleFingerTip: SIMD3(-0.038, 0.055, 0.02)
    ]) { $1 })

    static let pinch = HandPose(chirality: .right, timestamp: 0, joints: palm.merging([
        .thumbTip: SIMD3(0.04, 0.118, 0.045),
        .indexFingerTip: SIMD3(0.038, 0.12, 0.05),
        .middleFingerTip: SIMD3(0, 0.16, 0.03),
        .ringFingerTip: SIMD3(-0.028, 0.148, 0.03),
        .littleFingerTip: SIMD3(-0.052, 0.124, 0.028)
    ]) { $1 })
}

@Suite("HandShapeClassifier")
struct HandShapeClassifierTests {
    private let classifier = HandShapeClassifier()

    @Test("Hand-typed fixtures are classified", arguments: [
        (HandFixtures.openHand, HandShape.openPalm),
        (HandFixtures.fist, HandShape.fist),
        (HandFixtures.pinch, HandShape.pinch)
    ])
    func fixtures(pose: HandPose, expected: HandShape) {
        #expect(classifier.classify(pose).shape == expected)
    }

    @Test("Synthetic presets are classified for both hands, any size and any placement",
          arguments: HandShape.allCases, [HandPose.Chirality.left, .right])
    func syntheticPresets(shape: HandShape, chirality: HandPose.Chirality) {
        let placements = [
            Pose.identity,
            Pose(position: SIMD3(0.3, 1.2, -0.5), orientation: simd_quatf(angle: 2.1, axis: simd_normalize(SIMD3(1, 1, 0))))
        ]
        for palmLength: Float in [0.07, 0.11, 120] {
            for placement in placements {
                let pose = SyntheticHand(shape).pose(chirality: chirality, palmLength: palmLength, placedAt: placement)
                #expect(classifier.classify(pose).shape == shape, "palm \(palmLength), \(placement)")
            }
        }
    }

    @Test("A fist with the thumb resting on the index fingertip is not a pinch")
    func fistIsNotPinch() {
        var pose = HandFixtures.fist
        pose.setPosition(pose[.indexFingerTip], for: .thumbTip)
        let reading = classifier.classify(pose)
        #expect(reading.pinchDistance == 0)
        #expect(reading.shape == .fist)
    }

    @Test("Missing joints give .other and no measurements")
    func missingJoints() {
        let pose = HandPose(chirality: nil, timestamp: 0, joints: [.thumbTip: .zero, .indexFingerTip: SIMD3(0, 1, 0)])
        let reading = classifier.classify(pose)
        #expect(reading.shape == .other)
        #expect(reading.pinchDistance == nil)
        #expect(reading.fingerExtension.isEmpty)
    }

    @Test("A wrist on top of the knuckles cannot divide by zero")
    func degeneratePalm() {
        let pose = HandPose(chirality: .right, timestamp: 0, joints: [
            .wrist: .zero, .middleFingerKnuckle: .zero, .indexFingerKnuckle: .zero,
            .thumbTip: SIMD3(0, 0.1, 0), .indexFingerTip: SIMD3(0, 0.1, 0)
        ])
        #expect(HandShapeClassifier.palmLength(of: pose) == nil)
        #expect(classifier.classify(pose).shape == .other)
    }

    @Test("The palm length falls back to the index knuckle")
    func palmLengthFallback() {
        let pose = HandPose(chirality: .right, timestamp: 0, joints: [.wrist: .zero, .indexFingerKnuckle: SIMD3(0, 0.08, 0)])
        #expect(HandShapeClassifier.palmLength(of: pose) == 0.08)
    }

    @Test("Invalid thresholds fall back to the defaults and stay ordered")
    func sanitizesConfiguration() {
        let configuration = HandShapeClassifier.Configuration(pinchDistance: .nan, extendedRatio: -1, curledRatio: 3)
        #expect(configuration.pinchDistance == 0.25)
        #expect(configuration.extendedRatio == 1.5)
        #expect(configuration.curledRatio == 1.5)
    }
}

@Suite("HandPose")
struct HandPoseTests {
    @Test("Non-finite joints are dropped on creation and on update")
    func dropsNonFiniteJoints() {
        var pose = HandPose(chirality: .left, timestamp: .infinity,
                            joints: [.wrist: SIMD3(.nan, 0, 0), .thumbTip: SIMD3(0, 1, 0)])
        #expect(pose[.wrist] == nil)
        #expect(pose.timestamp == 0)
        pose.setPosition(SIMD3(0, .infinity, 0), for: .thumbTip)
        #expect(pose[.thumbTip] == nil)
    }

    @Test("Codable round trip keeps every joint")
    func codableRoundTrip() throws {
        let pose = SyntheticHand.pinch.pose(chirality: .left, timestamp: 12.5)
        let decoded = try JSONDecoder().decode(HandPose.self, from: JSONEncoder().encode(pose))
        #expect(decoded == pose)
        #expect(decoded.joints.count == HandJoint.allCases.count)
    }

    @Test("Unknown joint names are skipped")
    func unknownJoints() throws {
        let json = #"{"timestamp":1,"joints":{"wrist":[0,0,0],"sixthFingerTip":[1,2,3]}}"#
        let pose = try JSONDecoder().decode(HandPose.self, from: Data(json.utf8))
        #expect(pose.joints.keys.sorted { $0.rawValue < $1.rawValue } == [.wrist])
        #expect(pose.chirality == nil)
    }

    @Test("Malformed joints throw", arguments: [
        #"{"timestamp":1,"joints":{"wrist":[0,0]}}"#,
        #"{"timestamp":1,"joints":{"wrist":[0,0,1e40]}}"#,
        #"{"timestamp":1,"joints":{"wrist":"0,0,0"}}"#,
        #"{"joints":{}}"#
    ])
    func malformed(json: String) {
        #expect(throws: (any Error).self) { try JSONDecoder().decode(HandPose.self, from: Data(json.utf8)) }
    }
}
