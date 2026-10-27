#if canImport(RealityKit)
import RealityKit
import Testing
import simd
@testable import ARCraft

@Suite("Entity helpers")
@MainActor
struct EntityTests {
    @Test("setPose moves and turns an entity in its parent's space and keeps its scale")
    func setPose() throws {
        let parent = Entity()
        parent.position = SIMD3(0, 1, 0)
        let child = Entity()
        child.scale = SIMD3(repeating: 2)
        parent.addChild(child)
        let target = Pose(position: SIMD3(0.5, 0, 0), orientation: simd_quatf(angle: .pi / 3, axis: SIMD3(0, 1, 0)))
        child.setPose(target, relativeTo: parent)
        let local = try #require(child.pose(relativeTo: parent))
        #expect(local.isApproximatelyEqual(to: target))
        #expect(child.scale == SIMD3(repeating: 2))
        let world = try #require(child.pose())
        #expect(simd_distance(world.position, SIMD3(0.5, 1, 0)) < 1e-5)
    }

    @Test("scaleToFit shrinks a 2 m box into a 0.5 m volume")
    func scaleToFit() {
        let box = ModelEntity(mesh: .generateBox(size: 2))
        let factor = box.scaleToFit(SIMD3(repeating: 0.5))
        #expect(abs(factor - 0.25) < 1e-4)
        #expect(abs(box.scale.x - 0.25) < 1e-4)
    }

    @Test("An entity with nothing visible keeps scale 1")
    func emptyEntity() {
        let empty = Entity()
        #expect(empty.localSpatialBounds == nil)
        #expect(empty.scaleToFit(SIMD3(repeating: 0.1)) == 1)
    }
}
#endif
