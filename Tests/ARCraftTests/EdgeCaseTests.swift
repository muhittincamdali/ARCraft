import Foundation
import Testing
import simd
@testable import ARCraft

/// Inputs at the edges of what Float, Double and the configuration types accept. Each test checks
/// that the result is a usable value (finite, in range) rather than NaN, infinity or a trap.
@Suite("Edge cases")
struct EdgeCaseTests {
    @Test("SyntheticHand clamps NaN, negative and oversized amounts")
    func syntheticHandClamps() {
        let hand = SyntheticHand(curl: [.index: .nan, .middle: -3, .ring: 7], pinch: .infinity)
        #expect(hand.curl[.index] == 0)
        #expect(hand.curl[.middle] == 0)
        #expect(hand.curl[.ring] == 1)
        #expect(hand.pinch == 0)
        let blended = SyntheticHand.openPalm.interpolated(to: .fist, fraction: .nan)
        #expect(blended == SyntheticHand.openPalm.interpolated(to: .fist, fraction: 0))
    }

    @Test("A huge or invalid palm length never yields non-finite joints")
    func syntheticHandScale() {
        let huge = SyntheticHand.openPalm.pose(palmLength: .greatestFiniteMagnitude)
        let allFinite = huge.joints.values.allSatisfy { $0.isFinite }
        #expect(allFinite)
        let fallback = SyntheticHand.openPalm.pose(palmLength: -1)
        #expect(HandShapeClassifier.palmLength(of: fallback).map { abs($0 - 0.09) < 1e-5 } == true)
    }

    @Test("Placement near Float's limit throws instead of returning an infinite pose")
    func placementOverflow() {
        let solver = PlacementSolver(options: .init(surfaceOffset: .greatestFiniteMagnitude))
        let hit = SurfaceHit(position: SIMD3(0, .greatestFiniteMagnitude, 0), normal: SIMD3(0, 1, 0))
        #expect(throws: PlacementError.invalidHit) { try solver.place(on: hit, facing: .zero) }
    }

    @Test("A viewer at Float's limit still gives a finite orientation")
    func farViewer() throws {
        let hit = SurfaceHit(position: .zero, normal: SIMD3(0, 1, 0))
        let placement = try PlacementSolver().place(on: hit, facing: SIMD3(.greatestFiniteMagnitude, 0, -.greatestFiniteMagnitude))
        #expect(placement.pose.isFinite)
    }

    @Test("Bounds spanning nearly all of Float's range keep a finite center and a positive scale")
    func hugeBounds() throws {
        let bounds = try #require(SpatialBounds(min: SIMD3(repeating: -.greatestFiniteMagnitude),
                                                max: SIMD3(repeating: .greatestFiniteMagnitude)))
        #expect(bounds.center == .zero)
        let scale = bounds.scaleToFit(SIMD3(repeating: 1))
        #expect(scale > 0)
        #expect(scale.isFinite)
        let high = try #require(SpatialBounds(min: SIMD3(repeating: 3e38), max: SIMD3(repeating: .greatestFiniteMagnitude)))
        #expect(high.center.isFinite)
        #expect(high.restingOffset(scale: 1e-38).isFinite)
    }

    @Test("A large but finite scale clamps the resting offset instead of returning infinity")
    func restingOffsetOverflow() throws {
        let bounds = try #require(SpatialBounds(min: SIMD3(-1e30, -1e30, 1e30), max: SIMD3(1e30, 1e30, 1e30)))
        let offset = bounds.restingOffset(scale: 1e30)
        #expect(offset.isFinite)
        #expect(offset == SIMD3(0, .greatestFiniteMagnitude, -.greatestFiniteMagnitude))
        #expect(bounds.restingOffset(scale: 2) == SIMD3(0, 2e30, -2e30))
    }

    @Test("Composing poses that overflow is reported as non-finite and cannot be saved")
    func poseOverflow() {
        let far = Pose(position: SIMD3(repeating: .greatestFiniteMagnitude))
        let composed = far * far
        #expect(!composed.isFinite)
        let item = AnchoredItem(anchorID: UUID(), kind: "x", offset: composed)
        #expect(!PlacementArchive().isValid(item))
    }

    @Test("Filters accept a reset interval of any size without NaN")
    func hugeResetInterval() {
        var filter = OneEuroFilter<SIMD3<Float>>(configuration: .init(resetInterval: .greatestFiniteMagnitude))
        _ = filter.filter(SIMD3(0, 0, 0), at: 0)
        let output = filter.filter(SIMD3(1, 1, 1), at: 1e300)
        #expect(output.map(\.isFinite) == true)
        var poseFilter = PoseFilter(position: .init(resetInterval: 1e300), orientation: .init(resetInterval: 1e300))
        _ = poseFilter.filter(.identity, at: 0)
        let pose = poseFilter.filter(Pose(position: SIMD3(1, 0, 0)), at: 1e299)
        #expect(pose?.isFinite == true)
    }

    @Test("Gesture timestamps far apart or at Double's limit do not trap")
    func extremeTimestamps() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .fist, framesToBegin: 1))
        _ = recognizer.update(with: SyntheticHand.fist.pose(timestamp: -.greatestFiniteMagnitude))
        let later = SyntheticHand.fist.pose(timestamp: .greatestFiniteMagnitude)
        let events = recognizer.update(with: later)
        #expect(events == [.cancelled, .began(later)])
        #expect(recognizer.trackingLost(at: -.infinity) == nil)
    }
}
