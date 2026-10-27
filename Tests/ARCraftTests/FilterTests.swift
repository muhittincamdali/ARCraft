import Foundation
import Testing
import simd
@testable import ARCraft

/// A deterministic noise source so the statistics below do not depend on the run.
private struct SeededNoise {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    /// A value in `-amplitude...amplitude`.
    mutating func next(amplitude: Float) -> Float {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        let unit = Float(state >> 40) / Float(1 << 24)
        return (unit * 2 - 1) * amplitude
    }
}

private func variance(_ values: [Float]) -> Float {
    let mean = values.reduce(0, +) / Float(values.count)
    return values.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Float(values.count)
}

@Suite("OneEuroFilter")
struct OneEuroFilterTests {
    private let frameInterval: TimeInterval = 1.0 / 90

    @Test("The first sample passes through unchanged")
    func firstSamplePassesThrough() {
        var filter = OneEuroFilter<SIMD3<Float>>()
        #expect(filter.value == nil)
        #expect(filter.filter(SIMD3(1, 2, 3), at: 10) == SIMD3(1, 2, 3))
    }

    @Test("Jitter around a still point shrinks by more than 75 % in variance")
    func reducesJitter() {
        var filter = OneEuroFilter<SIMD2<Float>>(configuration: .handJoints)
        var noise = SeededNoise(seed: 42)
        var raw: [Float] = []
        var smoothed: [Float] = []
        for frame in 0..<900 {
            let sample = SIMD2<Float>(0.3 + noise.next(amplitude: 0.004), 0)
            let output = filter.filter(sample, at: Double(frame) * frameInterval)
            if frame >= 90 {
                raw.append(sample.x)
                smoothed.append(output?.x ?? .nan)
            }
        }
        #expect(variance(smoothed) < variance(raw) * 0.25)
    }

    @Test("A higher speed coefficient follows a fast move with less lag")
    func speedCoefficientReducesLag() {
        func lag(speedCoefficient: Float) -> Float {
            var filter = OneEuroFilter<SIMD2<Float>>(configuration: .init(minimumCutoff: 1, speedCoefficient: speedCoefficient))
            var output: Float = 0
            for frame in 0...90 {
                let time = Double(frame) * frameInterval
                output = filter.filter(SIMD2(Float(time) * 1.0, 0), at: time)?.x ?? .nan
            }
            return 1.0 - output
        }
        let still = lag(speedCoefficient: 0)
        let adaptive = lag(speedCoefficient: 10)
        #expect(adaptive < still * 0.5)
        #expect(adaptive >= 0)
    }

    @Test("NaN and infinite samples are ignored")
    func ignoresNonFiniteSamples() {
        var filter = OneEuroFilter<SIMD3<Float>>()
        _ = filter.filter(SIMD3(1, 1, 1), at: 0)
        #expect(filter.filter(SIMD3(.nan, 0, 0), at: 0.01) == SIMD3(1, 1, 1))
        #expect(filter.filter(SIMD3(0, .infinity, 0), at: 0.02) == SIMD3(1, 1, 1))
        #expect(filter.filter(SIMD3(1, 1, 1), at: .nan) == SIMD3(1, 1, 1))
        #expect(filter.value == SIMD3(1, 1, 1))
    }

    @Test("A NaN sample before any valid one yields nil")
    func nonFiniteFirstSample() {
        var filter = OneEuroFilter<SIMD2<Float>>()
        #expect(filter.filter(SIMD2(.nan, 0), at: 0) == nil)
    }

    @Test("Repeated and backwards timestamps are ignored")
    func ignoresStaleTimestamps() {
        var filter = OneEuroFilter<SIMD2<Float>>()
        _ = filter.filter(SIMD2(0, 0), at: 1)
        let moved = filter.filter(SIMD2(1, 0), at: 1.1)
        #expect(filter.filter(SIMD2(5, 0), at: 1.1) == moved)
        #expect(filter.filter(SIMD2(5, 0), at: 0.5) == moved)
    }

    @Test("A gap longer than the reset interval restarts the filter")
    func restartsAfterGap() {
        var filter = OneEuroFilter<SIMD2<Float>>(configuration: .init(resetInterval: 0.2))
        _ = filter.filter(SIMD2(0, 0), at: 0)
        _ = filter.filter(SIMD2(0.1, 0), at: 0.1)
        #expect(filter.filter(SIMD2(3, 0), at: 0.5) == SIMD2(3, 0))
    }

    @Test("Values near Float's limit never produce NaN")
    func extremeValues() {
        var filter = OneEuroFilter<SIMD2<Float>>()
        _ = filter.filter(SIMD2(-.greatestFiniteMagnitude, 0), at: 0)
        let output = filter.filter(SIMD2(.greatestFiniteMagnitude, 0), at: 1e-6)
        #expect(output.map { $0.x.isFinite && $0.y.isFinite } == true)
    }

    @Test("Invalid settings fall back to the defaults")
    func sanitizesConfiguration() {
        let configuration = OneEuroConfiguration(minimumCutoff: -1, speedCoefficient: .nan,
                                                 derivativeCutoff: 0, resetInterval: -.infinity)
        #expect(configuration == OneEuroConfiguration())
    }

    @Test("reset() makes the next sample pass through")
    func resetForgetsHistory() {
        var filter = OneEuroFilter<SIMD2<Float>>()
        _ = filter.filter(SIMD2(0, 0), at: 0)
        filter.reset()
        #expect(filter.value == nil)
        #expect(filter.filter(SIMD2(2, 2), at: 0.01) == SIMD2(2, 2))
    }
}

@Suite("PoseFilter")
struct PoseFilterTests {
    @Test("The orientation converges on a new, steady target")
    func orientationConverges() throws {
        var filter = PoseFilter()
        let target = simd_quatf(angle: .pi / 2, axis: SIMD3(0, 1, 0))
        _ = filter.filter(.identity, at: 0)
        var last: Pose?
        for frame in 1...180 {
            last = filter.filter(Pose(orientation: target), at: Double(frame) / 90)
        }
        let pose = try #require(last)
        #expect(SpatialMath.angle(between: pose.orientation, and: target) < 0.01)
    }

    @Test("q and -q are treated as the same orientation")
    func doubleCover() throws {
        var filter = PoseFilter()
        let rotation = simd_quatf(angle: 1, axis: SIMD3(0, 0, 1))
        _ = filter.filter(Pose(orientation: rotation), at: 0)
        let output = filter.filter(Pose(orientation: simd_quatf(vector: -rotation.vector)), at: 0.011)
        let pose = try #require(output)
        #expect(SpatialMath.angle(between: pose.orientation, and: rotation) < 1e-3)
    }

    @Test("Each step moves only part of the way toward a sudden jump")
    func smoothsJumps() throws {
        var filter = PoseFilter()
        _ = filter.filter(.identity, at: 0)
        let output = filter.filter(Pose(position: SIMD3(0.1, 0, 0)), at: 1.0 / 90)
        let pose = try #require(output)
        #expect(pose.position.x > 0)
        #expect(pose.position.x < 0.1)
    }

    @Test("A non-finite pose is ignored")
    func ignoresNonFinitePose() {
        var filter = PoseFilter()
        _ = filter.filter(Pose(position: SIMD3(1, 0, 0)), at: 0)
        let pose = filter.filter(Pose(position: SIMD3(.nan, 0, 0)), at: 0.01)
        #expect(pose?.position == SIMD3(1, 0, 0))
    }
}
