//
//  EntityTests.swift
//  ARCraftTests
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import XCTest
import simd
@testable import ARCraft

final class EntityTests: XCTestCase {
    
    // MARK: - Transform Tests
    
    func testTransformIdentity() {
        let transform = Transform3D.identity
        
        XCTAssertEqual(transform.position, .zero)
        XCTAssertEqual(transform.scale, SIMD3<Float>(1, 1, 1))
    }
    
    func testTransformFromMatrix() {
        var matrix = simd_float4x4.identity
        matrix.columns.3 = SIMD4<Float>(1, 2, 3, 1)
        
        let transform = Transform3D(matrix: matrix)
        
        XCTAssertEqual(transform.position.x, 1, accuracy: 0.001)
        XCTAssertEqual(transform.position.y, 2, accuracy: 0.001)
        XCTAssertEqual(transform.position.z, 3, accuracy: 0.001)
    }
    
    func testTransformToMatrix() {
        let transform = Transform3D(
            position: SIMD3<Float>(1, 2, 3),
            rotation: .identity,
            scale: SIMD3<Float>(2, 2, 2)
        )
        
        let matrix = transform.matrix
        
        XCTAssertEqual(matrix.columns.3.x, 1, accuracy: 0.001)
        XCTAssertEqual(matrix.columns.3.y, 2, accuracy: 0.001)
        XCTAssertEqual(matrix.columns.3.z, 3, accuracy: 0.001)
    }
    
    func testTransformLerp() {
        let a = Transform3D(position: .zero)
        let b = Transform3D(position: SIMD3<Float>(10, 0, 0))
        
        let result = Transform3D.lerp(a, b, t: 0.5)
        
        XCTAssertEqual(result.position.x, 5, accuracy: 0.001)
    }
    
    func testTransformDirections() {
        let transform = Transform3D.identity
        
        XCTAssertEqual(transform.forward.z, -1, accuracy: 0.001)
        XCTAssertEqual(transform.up.y, 1, accuracy: 0.001)
        XCTAssertEqual(transform.right.x, 1, accuracy: 0.001)
    }
    
    // MARK: - Entity Creation Tests
    
    func testEntityCreation() {
        let entity = ARCraftEntity(name: "TestEntity")
        
        XCTAssertEqual(entity.name, "TestEntity")
        XCTAssertEqual(entity.state, .active)
        XCTAssertTrue(entity.isEnabled)
        XCTAssertTrue(entity.isVisible)
        XCTAssertNil(entity.parent)
        XCTAssertTrue(entity.children.isEmpty)
    }
    
    func testEntityWithPosition() {
        let position = SIMD3<Float>(1, 2, 3)
        let entity = ARCraftEntity(name: "Test", position: position)
        
        XCTAssertEqual(entity.transform.position.x, 1, accuracy: 0.001)
        XCTAssertEqual(entity.transform.position.y, 2, accuracy: 0.001)
        XCTAssertEqual(entity.transform.position.z, 3, accuracy: 0.001)
    }
    
    // MARK: - Entity Hierarchy Tests
    
    func testAddChild() {
        let parent = ARCraftEntity(name: "Parent")
        let child = ARCraftEntity(name: "Child")
        
        parent.addChild(child)
        
        XCTAssertEqual(parent.children.count, 1)
        XCTAssertTrue(child.parent === parent)
    }
    
    func testRemoveChild() {
        let parent = ARCraftEntity(name: "Parent")
        let child = ARCraftEntity(name: "Child")
        
        parent.addChild(child)
        parent.removeChild(child)
        
        XCTAssertTrue(parent.children.isEmpty)
        XCTAssertNil(child.parent)
    }
    
    func testRemoveAllChildren() {
        let parent = ARCraftEntity(name: "Parent")
        parent.addChild(ARCraftEntity(name: "Child1"))
        parent.addChild(ARCraftEntity(name: "Child2"))
        parent.addChild(ARCraftEntity(name: "Child3"))
        
        XCTAssertEqual(parent.children.count, 3)
        
        parent.removeAllChildren()
        
        XCTAssertTrue(parent.children.isEmpty)
    }
    
    func testFindChildByName() {
        let parent = ARCraftEntity(name: "Parent")
        let child1 = ARCraftEntity(name: "Child1")
        let child2 = ARCraftEntity(name: "Child2")
        
        parent.addChild(child1)
        parent.addChild(child2)
        
        let found = parent.findChild(named: "Child2")
        
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Child2")
    }
    
    func testFindChildRecursive() {
        let parent = ARCraftEntity(name: "Parent")
        let child = ARCraftEntity(name: "Child")
        let grandChild = ARCraftEntity(name: "GrandChild")
        
        parent.addChild(child)
        child.addChild(grandChild)
        
        let found = parent.findChild(named: "GrandChild")
        
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "GrandChild")
    }
    
    func testAllDescendants() {
        let parent = ARCraftEntity(name: "Parent")
        let child1 = ARCraftEntity(name: "Child1")
        let child2 = ARCraftEntity(name: "Child2")
        let grandChild = ARCraftEntity(name: "GrandChild")
        
        parent.addChild(child1)
        parent.addChild(child2)
        child1.addChild(grandChild)
        
        let descendants = parent.allDescendants
        
        XCTAssertEqual(descendants.count, 3)
    }
    
    // MARK: - World Transform Tests
    
    func testWorldTransformNoParent() {
        let entity = ARCraftEntity(name: "Test")
        entity.transform.position = SIMD3<Float>(1, 2, 3)
        
        XCTAssertEqual(entity.worldPosition.x, 1, accuracy: 0.001)
        XCTAssertEqual(entity.worldPosition.y, 2, accuracy: 0.001)
        XCTAssertEqual(entity.worldPosition.z, 3, accuracy: 0.001)
    }
    
    func testWorldTransformWithParent() {
        let parent = ARCraftEntity(name: "Parent")
        parent.transform.position = SIMD3<Float>(10, 0, 0)
        
        let child = ARCraftEntity(name: "Child")
        child.transform.position = SIMD3<Float>(5, 0, 0)
        
        parent.addChild(child)
        
        XCTAssertEqual(child.worldPosition.x, 15, accuracy: 0.001)
    }
    
    // MARK: - Entity State Tests
    
    func testEntityStateTransitions() {
        let entity = ARCraftEntity(name: "Test")
        
        XCTAssertEqual(entity.state, .active)
        
        entity.pause()
        XCTAssertEqual(entity.state, .paused)
        
        entity.hide()
        XCTAssertEqual(entity.state, .hidden)
        XCTAssertFalse(entity.isVisible)
        
        entity.show()
        XCTAssertEqual(entity.state, .active)
        XCTAssertTrue(entity.isVisible)
    }
    
    // MARK: - Tag Tests
    
    func testEntityTags() {
        let entity = ARCraftEntity(name: "Test")
        
        entity.addTag("interactive")
        entity.addTag("player")
        
        XCTAssertTrue(entity.hasTag("interactive"))
        XCTAssertTrue(entity.hasTag("player"))
        XCTAssertFalse(entity.hasTag("enemy"))
        
        entity.removeTag("interactive")
        XCTAssertFalse(entity.hasTag("interactive"))
    }
    
    // MARK: - Distance Tests
    
    func testDistanceToEntity() {
        let entity1 = ARCraftEntity(name: "Entity1")
        entity1.transform.position = SIMD3<Float>(0, 0, 0)
        
        let entity2 = ARCraftEntity(name: "Entity2")
        entity2.transform.position = SIMD3<Float>(3, 4, 0)
        
        let distance = entity1.distance(to: entity2)
        
        XCTAssertEqual(distance, 5, accuracy: 0.001)
    }
    
    func testDistanceToPoint() {
        let entity = ARCraftEntity(name: "Test")
        entity.transform.position = .zero
        
        let distance = entity.distance(to: SIMD3<Float>(0, 0, 10))
        
        XCTAssertEqual(distance, 10, accuracy: 0.001)
    }
    
    // MARK: - Look At Tests
    
    func testLookAt() {
        let entity = ARCraftEntity(name: "Test")
        entity.transform.position = .zero
        
        entity.lookAt(SIMD3<Float>(0, 0, -10))
        
        let forward = entity.transform.forward
        XCTAssertEqual(forward.z, -1, accuracy: 0.01)
    }
}

// MARK: - Model Entity Tests

final class ModelEntityTests: XCTestCase {
    
    func testBoxCreation() {
        let box = ModelEntity.box(size: SIMD3<Float>(0.1, 0.2, 0.3))
        
        XCTAssertTrue(box.isLoaded)
        XCTAssertEqual(box.loadingState, .loaded)
        
        let bounds = box.localBounds
        XCTAssertEqual(bounds.extent.x, 0.1, accuracy: 0.001)
        XCTAssertEqual(bounds.extent.y, 0.2, accuracy: 0.001)
        XCTAssertEqual(bounds.extent.z, 0.3, accuracy: 0.001)
    }
    
    func testSphereCreation() {
        let sphere = ModelEntity.sphere(radius: 0.5)
        
        XCTAssertTrue(sphere.isLoaded)
        
        let bounds = sphere.localBounds
        XCTAssertEqual(bounds.extent.x, 1.0, accuracy: 0.001)
        XCTAssertEqual(bounds.extent.y, 1.0, accuracy: 0.001)
        XCTAssertEqual(bounds.extent.z, 1.0, accuracy: 0.001)
    }
    
    func testCylinderCreation() {
        let cylinder = ModelEntity.cylinder(radius: 0.25, height: 1.0)
        
        XCTAssertTrue(cylinder.isLoaded)
    }
    
    func testModelClone() {
        let original = ModelEntity.box(size: SIMD3<Float>(0.1, 0.1, 0.1))
        original.transform.position = SIMD3<Float>(1, 2, 3)
        original.castsShadow = false
        
        let clone = original.clone()
        
        XCTAssertNotEqual(original.id, clone.id)
        XCTAssertEqual(clone.transform.position.x, 1, accuracy: 0.001)
        XCTAssertFalse(clone.castsShadow)
    }
    
    func testWorldBounds() {
        let box = ModelEntity.box(size: SIMD3<Float>(1, 1, 1))
        box.transform.position = SIMD3<Float>(5, 0, 0)
        
        let worldBounds = box.worldBounds
        
        XCTAssertEqual(worldBounds.center.x, 5, accuracy: 0.001)
    }
}

// MARK: - Light Entity Tests

final class LightEntityTests: XCTestCase {
    
    func testDirectionalLightCreation() {
        let light = LightEntity.directionalLight(color: .daylight, intensity: 1000)
        
        XCTAssertEqual(light.lightType, .directional)
        XCTAssertEqual(light.intensity, 1000)
        XCTAssertTrue(light.isLightEnabled)
    }
    
    func testPointLightCreation() {
        let light = LightEntity.pointLight(color: .warmWhite, intensity: 500, radius: 10)
        
        XCTAssertEqual(light.lightType, .point)
        XCTAssertEqual(light.attenuationRadius, 10)
    }
    
    func testSpotLightCreation() {
        let light = LightEntity.spotLight(
            color: .white,
            intensity: 500,
            innerAngle: .pi / 8,
            outerAngle: .pi / 4
        )
        
        XCTAssertEqual(light.lightType, .spot)
        XCTAssertEqual(light.innerConeAngle, .pi / 8, accuracy: 0.001)
        XCTAssertEqual(light.outerConeAngle, .pi / 4, accuracy: 0.001)
    }
    
    func testLightAttenuation() {
        let light = LightEntity.pointLight(radius: 10)
        
        let attenuation0 = light.attenuation(at: 0)
        let attenuation5 = light.attenuation(at: 5)
        let attenuation10 = light.attenuation(at: 10)
        let attenuation15 = light.attenuation(at: 15)
        
        XCTAssertEqual(attenuation0, 1, accuracy: 0.001)
        XCTAssertTrue(attenuation5 > 0 && attenuation5 < 1)
        XCTAssertEqual(attenuation10, 0, accuracy: 0.001)
        XCTAssertEqual(attenuation15, 0, accuracy: 0.001)
    }
    
    func testLightToggle() {
        let light = LightEntity.pointLight()
        
        XCTAssertTrue(light.isLightEnabled)
        
        light.toggle()
        XCTAssertFalse(light.isLightEnabled)
        
        light.toggle()
        XCTAssertTrue(light.isLightEnabled)
    }
    
    func testLightColorFromTemperature() {
        let warmWhite = LightColor(temperature: 2700)
        let coolWhite = LightColor(temperature: 6500)
        
        // Warm white should be more red/yellow
        XCTAssertTrue(warmWhite.red > warmWhite.blue)
        
        // Cool white should be more balanced
        XCTAssertTrue(coolWhite.blue >= 0.9)
    }
}

// MARK: - Bounding Box Tests

final class BoundingBoxTests: XCTestCase {
    
    func testBoundingBoxCreation() {
        let box = BoundingBox(
            min: SIMD3<Float>(-1, -1, -1),
            max: SIMD3<Float>(1, 1, 1)
        )
        
        XCTAssertEqual(box.center, .zero)
        XCTAssertEqual(box.extent, SIMD3<Float>(2, 2, 2))
        XCTAssertEqual(box.volume, 8)
    }
    
    func testBoundingBoxContains() {
        let box = BoundingBox(
            min: SIMD3<Float>(0, 0, 0),
            max: SIMD3<Float>(1, 1, 1)
        )
        
        XCTAssertTrue(box.contains(SIMD3<Float>(0.5, 0.5, 0.5)))
        XCTAssertTrue(box.contains(SIMD3<Float>(0, 0, 0)))
        XCTAssertFalse(box.contains(SIMD3<Float>(-0.1, 0, 0)))
    }
    
    func testBoundingBoxUnion() {
        let box1 = BoundingBox(min: SIMD3<Float>(0, 0, 0), max: SIMD3<Float>(1, 1, 1))
        let box2 = BoundingBox(min: SIMD3<Float>(2, 0, 0), max: SIMD3<Float>(3, 1, 1))
        
        let union = box1.union(box2)
        
        XCTAssertEqual(union.min.x, 0)
        XCTAssertEqual(union.max.x, 3)
    }
    
    func testBoundingBoxIntersection() {
        let box1 = BoundingBox(min: SIMD3<Float>(0, 0, 0), max: SIMD3<Float>(2, 2, 2))
        let box2 = BoundingBox(min: SIMD3<Float>(1, 1, 1), max: SIMD3<Float>(3, 3, 3))
        
        let intersection = box1.intersection(box2)
        
        XCTAssertNotNil(intersection)
        XCTAssertEqual(intersection?.min, SIMD3<Float>(1, 1, 1))
        XCTAssertEqual(intersection?.max, SIMD3<Float>(2, 2, 2))
    }
    
    func testBoundingBoxNoIntersection() {
        let box1 = BoundingBox(min: SIMD3<Float>(0, 0, 0), max: SIMD3<Float>(1, 1, 1))
        let box2 = BoundingBox(min: SIMD3<Float>(2, 2, 2), max: SIMD3<Float>(3, 3, 3))
        
        let intersection = box1.intersection(box2)
        
        XCTAssertNil(intersection)
    }
}
