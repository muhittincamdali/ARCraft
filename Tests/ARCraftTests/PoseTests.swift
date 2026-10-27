import Foundation
import Testing
import simd
@testable import ARCraft

@Suite("Pose")
struct PoseTests {
    private let quarterTurnY = simd_quatf(angle: .pi / 2, axis: SIMD3(0, 1, 0))

    @Test("A matrix round-trips through Pose")
    func matrixRoundTrip() throws {
        let pose = Pose(position: SIMD3(1, 2, 3), orientation: quarterTurnY)
        let rebuilt = try #require(Pose(matrix: pose.matrix))
        #expect(rebuilt.isApproximatelyEqual(to: pose))
    }

    @Test("Scale is removed from a matrix")
    func scaleIsRemoved() throws {
        var matrix = Pose(position: SIMD3(0, 1, 0), orientation: quarterTurnY).matrix
        matrix.columns.0 *= 3
        matrix.columns.1 *= 0.5
        matrix.columns.2 *= 2
        let pose = try #require(Pose(matrix: matrix))
        #expect(pose.isApproximatelyEqual(to: Pose(position: SIMD3(0, 1, 0), orientation: quarterTurnY)))
    }

    @Test("Matrices with NaN, infinity, a zero axis or a mirror are rejected")
    func invalidMatrices() {
        var nan = matrix_identity_float4x4
        nan.columns.3.x = .nan
        var infinite = matrix_identity_float4x4
        infinite.columns.1.y = .infinity
        var flat = matrix_identity_float4x4
        flat.columns.2 = .zero
        var mirrored = matrix_identity_float4x4
        mirrored.columns.0.x = -1
        #expect(Pose(matrix: nan) == nil)
        #expect(Pose(matrix: infinite) == nil)
        #expect(Pose(matrix: flat) == nil)
        #expect(Pose(matrix: mirrored) == nil)
    }

    @Test("Composition applies the right-hand pose first")
    func composition() {
        let parent = Pose(position: SIMD3(0, 0, -2), orientation: quarterTurnY)
        let child = Pose(position: SIMD3(1, 0, 0))
        let world = parent * child
        // A quarter turn about +Y maps +X to -Z.
        #expect(simd_distance(world.position, SIMD3(0, 0, -3)) < 1e-5)
    }

    @Test("relative(to:) undoes composition")
    func relativeUndoesComposition() {
        let anchor = Pose(position: SIMD3(0.4, 1.1, -2), orientation: simd_quatf(angle: 0.7, axis: SIMD3(0, 1, 0)))
        let world = Pose(position: SIMD3(1, 0.9, -1.5), orientation: simd_quatf(angle: -0.3, axis: SIMD3(1, 0, 0)))
        let offset = world.relative(to: anchor)
        #expect((anchor * offset).isApproximatelyEqual(to: world))
    }

    @Test("A zero quaternion becomes the identity orientation")
    func zeroQuaternion() {
        let pose = Pose(orientation: simd_quatf(vector: .zero))
        #expect(pose.orientation.vector == SIMD4(0, 0, 0, 1))
    }

    @Test("Codable round trip keeps the pose")
    func codableRoundTrip() throws {
        let pose = Pose(position: SIMD3(0.25, -1, 3.5), orientation: quarterTurnY)
        let data = try JSONEncoder().encode(pose)
        let decoded = try JSONDecoder().decode(Pose.self, from: data)
        #expect(decoded.isApproximatelyEqual(to: pose))
    }

    @Test("Decoding rejects malformed poses", arguments: [
        #"{"position":[0,0],"orientation":[0,0,0,1]}"#,
        #"{"position":[0,0,0],"orientation":[0,0,0,0]}"#,
        #"{"position":[0,0,0],"orientation":[0,0,1]}"#,
        #"{"position":[1e39,0,0],"orientation":[0,0,0,1]}"#,
        #"{"position":"0,0,0","orientation":[0,0,0,1]}"#
    ])
    func decodingRejects(json: String) {
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(Pose.self, from: Data(json.utf8))
        }
    }

    @Test("Encoding a non-finite pose throws instead of writing invalid JSON")
    func encodingRejectsNaN() {
        let pose = Pose(position: SIMD3(.nan, 0, 0))
        #expect(!pose.isFinite)
        #expect(throws: EncodingError.self) { try JSONEncoder().encode(pose) }
    }
}
