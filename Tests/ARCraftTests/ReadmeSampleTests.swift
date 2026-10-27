import Foundation
import Testing
import simd
@testable import ARCraft

/// Runs the README samples (compiled from the example app through `ReadmeExamples.swift`) and
/// checks that they do what the README says.
@Suite("README samples")
struct ReadmeSampleTests {
    @Test("The quick start recognizes one pinch and its release")
    func quickStart() {
        // Frames 3 and 4 are closed enough (two frames to begin); frames 7 to 9 are open past
        // the release distance (three frames to end).
        #expect(ReadmeSamples.quickStart() == ["pinch began at frame 4", "pinch ended at frame 9"])
    }

    @Test("Smoothing keeps one output per sample and stays near a still fingertip")
    func smoothing() {
        let samples = (0..<90).map { frame in
            (time: Double(frame) / 90, position: SIMD3<Float>(0.1, 1.2, -0.4) + SIMD3(frame % 2 == 0 ? 0.002 : -0.002, 0, 0))
        }
        let smoothed = ReadmeSamples.smoothFingertip(samples)
        #expect(smoothed.count == samples.count)
        let last = smoothed.last ?? .zero
        #expect(simd_distance(last, SIMD3(0.1, 1.2, -0.4)) < 0.002)
    }

    @Test("The table placement is snapped to the grid and to a 45° turn")
    func placement() throws {
        let placement = try ReadmeSamples.placeOnTable()
        #expect(placement.surface == .floor)
        let position = placement.pose.position
        #expect(simd_distance(position, SIMD3(0.4, 0.74, -0.8)) < 1e-5)
        let front = placement.pose.rotate(SIMD3(0, 0, 1))
        let yaw = atan2(front.x, front.z)
        let steps = yaw / (.pi / 4)
        #expect(abs(steps - steps.rounded()) < 1e-4)
    }

    @Test("A 120 cm wide model is scaled to fit 30 cm")
    func fit() {
        #expect(abs(ReadmeSamples.fitModel() - 0.0025) < 1e-6)
    }

    @Test("A saved item is restored at its world pose")
    func persistence() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ARCraftReadme-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: folder) }
        let statuses = try await ReadmeSamples.saveAndRestore(in: folder)
        #expect(statuses.count == 1)
        guard case .placed(let pose) = statuses.first else {
            Issue.record("Expected the lamp to be placed")
            return
        }
        #expect(simd_distance(pose.position, SIMD3(0.2, 0.8, -1.1)) < 1e-5)
    }
}
