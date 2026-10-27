import Foundation
import Testing
import simd
@testable import ARCraft

@Suite("SurfaceOrientation")
struct SurfaceOrientationTests {
    @Test("Normals are classified with a tolerance", arguments: [
        (SIMD3<Float>(0, 1, 0), SurfaceOrientation.floor),
        (SIMD3<Float>(0.1, 1, 0), .floor),
        (SIMD3<Float>(0, -3, 0), .ceiling),
        (SIMD3<Float>(1, 0, 0), .wall),
        (SIMD3<Float>(0, 0.2, -1), .wall),
        (SIMD3<Float>(1, 1, 0), .slope)
    ])
    func classifies(normal: SIMD3<Float>, expected: SurfaceOrientation) {
        #expect(SurfaceOrientation(normal: normal) == expected)
    }

    @Test("Zero and non-finite normals are rejected")
    func rejectsInvalidNormals() {
        #expect(SurfaceOrientation(normal: .zero) == nil)
        #expect(SurfaceOrientation(normal: SIMD3(.nan, 1, 0)) == nil)
    }
}

@Suite("PlacementSolver")
struct PlacementSolverTests {
    private let viewer = SIMD3<Float>(0, 1.6, 0)

    /// The content's front (+Z) in world space.
    private func front(of placement: Placement) -> SIMD3<Float> {
        placement.pose.rotate(SIMD3(0, 0, 1))
    }

    @Test("On a floor the content stands upright and faces the viewer")
    func floorFacesViewer() throws {
        let hit = SurfaceHit(position: SIMD3(1, 0, -1), normal: SIMD3(0, 1, 0))
        let placement = try PlacementSolver().place(on: hit, facing: viewer)
        #expect(placement.surface == .floor)
        #expect(placement.pose.position == SIMD3(1, 0, -1))
        #expect(simd_distance(placement.pose.rotate(SIMD3(0, 1, 0)), SIMD3(0, 1, 0)) < 1e-5)
        let expected = simd_normalize(SIMD3<Float>(-1, 0, 1))
        #expect(simd_distance(front(of: placement), expected) < 1e-5)
    }

    @Test("A slightly tilted table keeps content upright unless alignment is requested")
    func tiltedTable() throws {
        let hit = SurfaceHit(position: .zero, normal: SIMD3(0.15, 1, 0))
        let upright = try PlacementSolver().place(on: hit, facing: SIMD3(0, 1, 2))
        #expect(simd_distance(upright.pose.rotate(SIMD3(0, 1, 0)), SIMD3(0, 1, 0)) < 1e-5)
        let aligned = try PlacementSolver(options: .init(alignsToSurfaceNormal: true)).place(on: hit, facing: SIMD3(0, 1, 2))
        #expect(simd_distance(aligned.pose.rotate(SIMD3(0, 1, 0)), simd_normalize(hit.normal)) < 1e-5)
    }

    @Test("On a wall the content faces out of the wall and stays upright")
    func wallFacesOut() throws {
        let hit = SurfaceHit(position: SIMD3(0, 1.4, -2), normal: SIMD3(0, 0, 1))
        let placement = try PlacementSolver().place(on: hit, facing: viewer)
        #expect(placement.surface == .wall)
        #expect(simd_distance(front(of: placement), SIMD3(0, 0, 1)) < 1e-5)
        #expect(simd_distance(placement.pose.rotate(SIMD3(0, 1, 0)), SIMD3(0, 1, 0)) < 1e-5)
    }

    @Test("Grid snapping rounds in the surface plane and keeps the surface height")
    func gridSnapping() throws {
        let solver = PlacementSolver(options: .init(gridSize: 0.25))
        let floor = try solver.place(on: SurfaceHit(position: SIMD3(0.37, 0.71, -1.12), normal: SIMD3(0, 1, 0)), facing: viewer)
        #expect(simd_distance(floor.pose.position, SIMD3(0.25, 0.71, -1.0)) < 1e-5)
        let wall = try solver.place(on: SurfaceHit(position: SIMD3(0.37, 1.38, -2), normal: SIMD3(0, 0, 1)), facing: viewer)
        #expect(simd_distance(wall.pose.position, SIMD3(0.25, 1.5, -2)) < 1e-5)
    }

    @Test("Rotation snapping turns in fixed steps")
    func rotationSnapping() throws {
        let solver = PlacementSolver(options: .init(rotationStep: .pi / 2))
        // The viewer is 30° off the +Z axis; a 90° step rounds that to 0°.
        let viewer = SIMD3<Float>(sin(.pi / 6), 1.6, cos(.pi / 6)) * 2
        let placement = try solver.place(on: SurfaceHit(position: .zero, normal: SIMD3(0, 1, 0)), facing: viewer)
        #expect(simd_distance(front(of: placement), SIMD3(0, 0, 1)) < 1e-5)
    }

    @Test("The surface offset lifts content along the normal")
    func surfaceOffset() throws {
        let placement = try PlacementSolver(options: .init(surfaceOffset: 0.02))
            .place(on: SurfaceHit(position: SIMD3(0, 0, -2), normal: SIMD3(0, 0, 5)), facing: viewer)
        #expect(simd_distance(placement.pose.position, SIMD3(0, 0, -1.98)) < 1e-5)
    }

    @Test("A viewer straight above the hit still gives a valid orientation")
    func viewerAbove() throws {
        let placement = try PlacementSolver().place(on: SurfaceHit(position: .zero, normal: SIMD3(0, 1, 0)), facing: SIMD3(0, 2, 0))
        #expect(placement.pose.isFinite)
    }

    @Test("Invalid input and excluded surfaces throw typed errors")
    func errors() {
        let solver = PlacementSolver()
        #expect(throws: PlacementError.invalidHit) {
            try solver.place(on: SurfaceHit(position: .zero, normal: .zero), facing: viewer)
        }
        #expect(throws: PlacementError.invalidHit) {
            try solver.place(on: SurfaceHit(position: SIMD3(.infinity, 0, 0), normal: SIMD3(0, 1, 0)), facing: viewer)
        }
        #expect(throws: PlacementError.invalidViewer) {
            try solver.place(on: SurfaceHit(position: .zero, normal: SIMD3(0, 1, 0)), facing: SIMD3(.nan, 0, 0))
        }
        #expect(throws: PlacementError.surfaceNotAllowed(.ceiling)) {
            try solver.place(on: SurfaceHit(position: SIMD3(0, 2.5, 0), normal: SIMD3(0, -1, 0)), facing: viewer)
        }
    }

    @Test("Invalid option values turn the feature off")
    func sanitizesOptions() {
        let options = PlacementOptions(gridSize: 0, rotationStep: .nan, surfaceOffset: .infinity)
        #expect(options.gridSize == nil)
        #expect(options.rotationStep == nil)
        #expect(options.surfaceOffset == 0)
    }

    @Test("Snapping far from the origin cannot overflow")
    func snappingFarAway() throws {
        let solver = PlacementSolver(options: .init(gridSize: 0.001))
        let placement = try solver.place(on: SurfaceHit(position: SIMD3(3e38, 0, 0), normal: SIMD3(0, 1, 0)), facing: viewer)
        #expect(placement.pose.position.isFinite)
    }
}

@Suite("SpatialBounds")
struct SpatialBoundsTests {
    @Test("Bounds from points ignore non-finite points")
    func fromPoints() throws {
        let bounds = try #require(SpatialBounds(points: [SIMD3(1, 2, 3), SIMD3(-1, 0, 5), SIMD3(.nan, 0, 0)]))
        #expect(bounds.min == SIMD3(-1, 0, 3))
        #expect(bounds.max == SIMD3(1, 2, 5))
        #expect(SpatialBounds(points: [SIMD3<Float>]()) == nil)
        #expect(SpatialBounds(min: SIMD3(.infinity, 0, 0), max: SIMD3(.infinity, 1, 1)) == nil)
        #expect(SpatialBounds(min: SIMD3(1, 0, 0), max: SIMD3(0, 1, 1)) == nil)
    }

    @Test("A 2 m model fits a 0.5 m volume at a quarter of its size")
    func scaleDown() throws {
        let bounds = try #require(SpatialBounds(min: SIMD3(-1, 0, -0.5), max: SIMD3(1, 1, 0.5)))
        #expect(bounds.scaleToFit(SIMD3(repeating: 0.5)) == 0.25)
    }

    @Test("Small models are only enlarged when asked")
    func upscaling() throws {
        let bounds = try #require(SpatialBounds(min: .zero, max: SIMD3(0.1, 0.1, 0.1)))
        #expect(bounds.scaleToFit(SIMD3(repeating: 1)) == 1)
        #expect(abs(bounds.scaleToFit(SIMD3(repeating: 1), allowsUpscaling: true) - 10) < 1e-4)
    }

    @Test("Flat boxes and unusable targets do not produce zero or infinity")
    func degenerate() throws {
        let plane = try #require(SpatialBounds(min: .zero, max: SIMD3(2, 0, 2)))
        #expect(plane.scaleToFit(SIMD3(1, 1, 1)) == 0.5)
        let point = try #require(SpatialBounds(min: .zero, max: .zero))
        #expect(point.scaleToFit(SIMD3(1, 1, 1), allowsUpscaling: true) == 1)
        let box = try #require(SpatialBounds(min: .zero, max: SIMD3(1, 1, 1)))
        #expect(box.scaleToFit(SIMD3(0, -1, .nan)) == 1)
    }

    @Test("The resting offset puts the bottom center at the origin")
    func restingOffset() throws {
        let bounds = try #require(SpatialBounds(min: SIMD3(1, -0.5, 2), max: SIMD3(3, 1.5, 4)))
        #expect(bounds.restingOffset() == SIMD3(-2, 0.5, -3))
        #expect(bounds.restingOffset(scale: 0.5) == SIMD3(-1, 0.25, -1.5))
    }
}
