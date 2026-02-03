//
//  AnchorTests.swift
//  ARCraftTests
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import XCTest
import simd
@testable import ARCraft

final class AnchorManagerTests: XCTestCase {
    
    var anchorManager: AnchorManager!
    
    override func setUp() {
        super.setUp()
        anchorManager = AnchorManager()
    }
    
    override func tearDown() {
        anchorManager = nil
        super.tearDown()
    }
    
    // MARK: - Anchor Creation Tests
    
    func testCreateWorldAnchor() {
        let position = SIMD3<Float>(1, 2, 3)
        let anchor = anchorManager.createWorldAnchor(at: position, name: "TestAnchor")
        
        XCTAssertEqual(anchor.data.name, "TestAnchor")
        XCTAssertEqual(anchor.data.type, .world)
        XCTAssertEqual(anchor.data.position.x, position.x, accuracy: 0.001)
        XCTAssertEqual(anchor.data.position.y, position.y, accuracy: 0.001)
        XCTAssertEqual(anchor.data.position.z, position.z, accuracy: 0.001)
    }
    
    func testCreatePlaneAnchor() {
        let center = SIMD3<Float>(0, 0, 0)
        let extent = SIMD3<Float>(1, 0, 1)
        
        let anchor = anchorManager.createPlaneAnchor(
            center: center,
            extent: extent,
            alignment: .horizontal,
            name: "FloorPlane"
        )
        
        XCTAssertEqual(anchor.data.type, .plane)
        XCTAssertNotNil(anchor.userData["alignment"])
    }
    
    // MARK: - Anchor Management Tests
    
    func testAnchorCount() {
        XCTAssertEqual(anchorManager.anchorCount, 0)
        
        anchorManager.createWorldAnchor(at: .zero)
        XCTAssertEqual(anchorManager.anchorCount, 1)
        
        anchorManager.createWorldAnchor(at: SIMD3<Float>(1, 0, 0))
        XCTAssertEqual(anchorManager.anchorCount, 2)
    }
    
    func testRemoveAnchor() {
        let anchor = anchorManager.createWorldAnchor(at: .zero)
        XCTAssertEqual(anchorManager.anchorCount, 1)
        
        anchorManager.removeAnchor(id: anchor.id)
        XCTAssertEqual(anchorManager.anchorCount, 0)
    }
    
    func testRemoveAllAnchors() {
        anchorManager.createWorldAnchor(at: .zero)
        anchorManager.createWorldAnchor(at: SIMD3<Float>(1, 0, 0))
        anchorManager.createWorldAnchor(at: SIMD3<Float>(0, 1, 0))
        
        XCTAssertEqual(anchorManager.anchorCount, 3)
        
        anchorManager.removeAllAnchors()
        XCTAssertEqual(anchorManager.anchorCount, 0)
    }
    
    // MARK: - Anchor Query Tests
    
    func testQueryByType() {
        anchorManager.createWorldAnchor(at: .zero)
        anchorManager.createPlaneAnchor(center: .zero, extent: SIMD3<Float>(1, 0, 1), alignment: .horizontal)
        
        let worldAnchors = anchorManager.anchors(ofType: .world)
        let planeAnchors = anchorManager.anchors(ofType: .plane)
        
        XCTAssertEqual(worldAnchors.count, 1)
        XCTAssertEqual(planeAnchors.count, 1)
    }
    
    func testQueryWithFilter() {
        anchorManager.createWorldAnchor(at: SIMD3<Float>(0, 0, 0), name: "Anchor1")
        anchorManager.createWorldAnchor(at: SIMD3<Float>(10, 0, 0), name: "Anchor2")
        
        let nearFilter = AnchorFilter(
            nearPosition: .zero,
            maxDistance: 5
        )
        
        let nearAnchors = anchorManager.query(filter: nearFilter)
        XCTAssertEqual(nearAnchors.count, 1)
    }
    
    func testNearestAnchor() {
        anchorManager.createWorldAnchor(at: SIMD3<Float>(0, 0, 0))
        anchorManager.createWorldAnchor(at: SIMD3<Float>(5, 0, 0))
        anchorManager.createWorldAnchor(at: SIMD3<Float>(10, 0, 0))
        
        let nearest = anchorManager.nearestAnchor(to: SIMD3<Float>(4, 0, 0))
        
        XCTAssertNotNil(nearest)
        XCTAssertEqual(nearest?.data.position.x, 5, accuracy: 0.001)
    }
    
    func testAnchorsWithinRadius() {
        anchorManager.createWorldAnchor(at: SIMD3<Float>(0, 0, 0))
        anchorManager.createWorldAnchor(at: SIMD3<Float>(2, 0, 0))
        anchorManager.createWorldAnchor(at: SIMD3<Float>(10, 0, 0))
        
        let nearby = anchorManager.anchors(within: 5, of: .zero)
        
        XCTAssertEqual(nearby.count, 2)
    }
    
    // MARK: - Tracking State Tests
    
    func testUpdateTrackingState() {
        let anchor = anchorManager.createWorldAnchor(at: .zero)
        XCTAssertEqual(anchor.trackingState, .tracking)
        
        anchorManager.updateTrackingState(for: anchor.id, state: .limited)
        XCTAssertEqual(anchor.trackingState, .limited)
    }
    
    // MARK: - Persistence Tests
    
    func testMarkPersistent() {
        let anchor = anchorManager.createWorldAnchor(at: .zero)
        XCTAssertFalse(anchor.isPersistent)
        
        anchorManager.markPersistent(id: anchor.id)
        XCTAssertTrue(anchor.isPersistent)
        
        XCTAssertEqual(anchorManager.persistentAnchors.count, 1)
    }
    
    // MARK: - Entity Association Tests
    
    func testEntityAssociation() {
        let anchor = anchorManager.createWorldAnchor(at: .zero)
        let entityID = UUID()
        
        anchorManager.associateEntity(entityID, with: anchor.id)
        XCTAssertTrue(anchor.associatedEntities.contains(entityID))
        
        let anchorsForEntity = anchorManager.anchors(for: entityID)
        XCTAssertEqual(anchorsForEntity.count, 1)
        
        anchorManager.removeEntityAssociation(entityID, from: anchor.id)
        XCTAssertFalse(anchor.associatedEntities.contains(entityID))
    }
    
    // MARK: - Statistics Tests
    
    func testComputeStatistics() {
        anchorManager.createWorldAnchor(at: .zero)
        anchorManager.createWorldAnchor(at: SIMD3<Float>(1, 0, 0))
        anchorManager.createPlaneAnchor(center: .zero, extent: SIMD3<Float>(1, 0, 1), alignment: .horizontal)
        
        let stats = anchorManager.computeStatistics()
        
        XCTAssertEqual(stats.totalCount, 3)
        XCTAssertEqual(stats.countByType[.world], 2)
        XCTAssertEqual(stats.countByType[.plane], 1)
    }
}

// MARK: - Plane Anchor Tests

final class PlaneAnchorTests: XCTestCase {
    
    func testPlaneAnchorCreation() {
        let center = SIMD3<Float>(0, 0, 0)
        let extent = SIMD3<Float>(2, 0, 3)
        
        let plane = PlaneAnchor(
            center: center,
            extent: extent,
            alignment: .horizontal,
            classification: .floor
        )
        
        XCTAssertEqual(plane.alignment, .horizontal)
        XCTAssertEqual(plane.classification, .floor)
        XCTAssertEqual(plane.width, 2)
        XCTAssertEqual(plane.height, 3)
        XCTAssertEqual(plane.area, 6)
    }
    
    func testPlaneContainsPoint() {
        let plane = PlaneAnchor(
            center: SIMD3<Float>(0, 0, 0),
            extent: SIMD3<Float>(2, 0, 2),
            alignment: .horizontal
        )
        
        XCTAssertTrue(plane.contains(point: SIMD3<Float>(0, 0, 0)))
        XCTAssertTrue(plane.contains(point: SIMD3<Float>(0.5, 0, 0.5)))
        XCTAssertFalse(plane.contains(point: SIMD3<Float>(2, 0, 0)))
        XCTAssertFalse(plane.contains(point: SIMD3<Float>(0, 1, 0)))
    }
    
    func testPlaneProjectPoint() {
        let plane = PlaneAnchor(
            center: SIMD3<Float>(0, 0, 0),
            extent: SIMD3<Float>(10, 0, 10),
            alignment: .horizontal
        )
        
        let point = SIMD3<Float>(1, 5, 1)
        let projected = plane.project(point: point)
        
        XCTAssertEqual(projected.x, 1, accuracy: 0.001)
        XCTAssertEqual(projected.y, 0, accuracy: 0.001)
        XCTAssertEqual(projected.z, 1, accuracy: 0.001)
    }
    
    func testPlaneSignedDistance() {
        let plane = PlaneAnchor(
            center: SIMD3<Float>(0, 0, 0),
            extent: SIMD3<Float>(10, 0, 10),
            alignment: .horizontal
        )
        
        let above = plane.signedDistance(to: SIMD3<Float>(0, 5, 0))
        let below = plane.signedDistance(to: SIMD3<Float>(0, -3, 0))
        
        XCTAssertEqual(above, 5, accuracy: 0.001)
        XCTAssertEqual(below, -3, accuracy: 0.001)
    }
    
    func testPlaneCorners() {
        let plane = PlaneAnchor(
            center: SIMD3<Float>(0, 0, 0),
            extent: SIMD3<Float>(2, 0, 2),
            alignment: .horizontal
        )
        
        let corners = plane.corners
        XCTAssertEqual(corners.count, 4)
    }
    
    func testPlaneClassificationAlignment() {
        XCTAssertEqual(PlaneClassification.floor.typicalAlignment, .horizontal)
        XCTAssertEqual(PlaneClassification.ceiling.typicalAlignment, .horizontal)
        XCTAssertEqual(PlaneClassification.table.typicalAlignment, .horizontal)
        XCTAssertEqual(PlaneClassification.wall.typicalAlignment, .vertical)
        XCTAssertEqual(PlaneClassification.door.typicalAlignment, .vertical)
    }
}

// MARK: - Image Anchor Tests

final class ImageAnchorTests: XCTestCase {
    
    func testImageReferenceCreation() {
        let reference = ImageReference(
            name: "poster",
            physicalWidth: 0.3,
            physicalHeight: 0.4
        )
        
        XCTAssertEqual(reference.name, "poster")
        XCTAssertEqual(reference.physicalWidth, 0.3)
        XCTAssertEqual(reference.physicalHeight, 0.4)
        XCTAssertEqual(reference.aspectRatio, 0.75, accuracy: 0.001)
    }
    
    func testImageAnchorCreation() {
        let reference = ImageReference(name: "test", physicalWidth: 0.2)
        let anchor = ImageAnchor(
            reference: reference,
            transform: matrix_identity_float4x4
        )
        
        XCTAssertEqual(anchor.reference.name, "test")
        XCTAssertTrue(anchor.isTracked)
        XCTAssertEqual(anchor.trackingState, .tracking)
    }
    
    func testImageAnchorUpdate() {
        let reference = ImageReference(name: "test", physicalWidth: 0.2)
        let anchor = ImageAnchor(reference: reference, transform: matrix_identity_float4x4)
        
        var newTransform = matrix_identity_float4x4
        newTransform.columns.3 = SIMD4<Float>(1, 2, 3, 1)
        
        anchor.update(
            transform: newTransform,
            trackingState: .limited,
            scale: 1.1,
            confidence: 0.9
        )
        
        XCTAssertEqual(anchor.trackingState, .limited)
        XCTAssertEqual(anchor.estimatedScale, 1.1, accuracy: 0.001)
        XCTAssertEqual(anchor.confidence, 0.9, accuracy: 0.001)
        XCTAssertEqual(anchor.position.x, 1, accuracy: 0.001)
    }
    
    func testImageAnchorContainsPoint() {
        let reference = ImageReference(name: "test", physicalWidth: 0.2)
        let anchor = ImageAnchor(reference: reference, transform: matrix_identity_float4x4)
        
        XCTAssertTrue(anchor.contains(point: SIMD3<Float>(0, 0, 0)))
    }
}

// MARK: - Object Anchor Tests

final class ObjectAnchorTests: XCTestCase {
    
    func testObjectReferenceCreation() {
        let reference = ObjectReference(
            name: "cup",
            center: SIMD3<Float>(0, 0.05, 0),
            extent: SIMD3<Float>(0.08, 0.1, 0.08)
        )
        
        XCTAssertEqual(reference.name, "cup")
        XCTAssertEqual(reference.volume, 0.08 * 0.1 * 0.08, accuracy: 0.00001)
    }
    
    func testObjectAnchorContainsPoint() {
        let reference = ObjectReference(
            name: "box",
            center: .zero,
            extent: SIMD3<Float>(1, 1, 1)
        )
        let anchor = ObjectAnchor(reference: reference, transform: matrix_identity_float4x4)
        
        XCTAssertTrue(anchor.contains(point: SIMD3<Float>(0, 0, 0)))
        XCTAssertTrue(anchor.contains(point: SIMD3<Float>(0.4, 0.4, 0.4)))
        XCTAssertFalse(anchor.contains(point: SIMD3<Float>(1, 1, 1)))
    }
    
    func testObjectAnchorWorldBoundingBox() {
        let reference = ObjectReference(
            name: "box",
            center: .zero,
            extent: SIMD3<Float>(2, 2, 2)
        )
        let anchor = ObjectAnchor(reference: reference, transform: matrix_identity_float4x4)
        
        let bounds = anchor.worldBoundingBox
        
        XCTAssertEqual(bounds.min.x, -1, accuracy: 0.001)
        XCTAssertEqual(bounds.max.x, 1, accuracy: 0.001)
    }
}
