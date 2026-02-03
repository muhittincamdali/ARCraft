//
//  ARSessionTests.swift
//  ARCraftTests
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import ARCraft

final class ARSessionTests: XCTestCase {
    
    // MARK: - Session State Tests
    
    func testSessionStateDescription() {
        XCTAssertEqual(ARSessionState.notStarted.description, "Not Started")
        XCTAssertEqual(ARSessionState.initializing.description, "Initializing")
        XCTAssertEqual(ARSessionState.running.description, "Running")
        XCTAssertEqual(ARSessionState.paused.description, "Paused")
        XCTAssertEqual(ARSessionState.error.description, "Error")
        XCTAssertEqual(ARSessionState.stopped.description, "Stopped")
    }
    
    func testSessionStateIsActive() {
        XCTAssertFalse(ARSessionState.notStarted.isActive)
        XCTAssertTrue(ARSessionState.initializing.isActive)
        XCTAssertTrue(ARSessionState.running.isActive)
        XCTAssertFalse(ARSessionState.paused.isActive)
        XCTAssertFalse(ARSessionState.error.isActive)
        XCTAssertFalse(ARSessionState.stopped.isActive)
    }
    
    // MARK: - Tracking Quality Tests
    
    func testTrackingQualityComparison() {
        XCTAssertTrue(ARTrackingQuality.notAvailable < ARTrackingQuality.limited)
        XCTAssertTrue(ARTrackingQuality.limited < ARTrackingQuality.normal)
        XCTAssertTrue(ARTrackingQuality.normal < ARTrackingQuality.excellent)
    }
    
    func testTrackingQualityDescription() {
        XCTAssertEqual(ARTrackingQuality.notAvailable.description, "Not Available")
        XCTAssertEqual(ARTrackingQuality.limited.description, "Limited")
        XCTAssertEqual(ARTrackingQuality.normal.description, "Normal")
        XCTAssertEqual(ARTrackingQuality.excellent.description, "Excellent")
    }
    
    // MARK: - Session Error Tests
    
    func testSessionErrorDescriptions() {
        XCTAssertNotNil(ARSessionError.notSupported.errorDescription)
        XCTAssertNotNil(ARSessionError.cameraAccessDenied.errorDescription)
        XCTAssertNotNil(ARSessionError.worldTrackingFailed("Test").errorDescription)
        XCTAssertNotNil(ARSessionError.invalidConfiguration.errorDescription)
        XCTAssertNotNil(ARSessionError.timeout.errorDescription)
    }
    
    func testSessionErrorRecoverySuggestions() {
        XCTAssertNotNil(ARSessionError.notSupported.recoverySuggestion)
        XCTAssertNotNil(ARSessionError.cameraAccessDenied.recoverySuggestion)
        XCTAssertNotNil(ARSessionError.insufficientLighting.recoverySuggestion)
        XCTAssertNotNil(ARSessionError.excessiveMotion.recoverySuggestion)
    }
    
    // MARK: - Frame Data Tests
    
    func testFrameDataCameraPosition() {
        let transform = simd_float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(1, 2, 3, 1)
        )
        
        let frame = ARFrameData(
            timestamp: 0,
            cameraTransform: transform,
            projectionMatrix: matrix_identity_float4x4,
            lightEstimate: nil,
            trackingQuality: .normal
        )
        
        XCTAssertEqual(frame.cameraPosition.x, 1, accuracy: 0.001)
        XCTAssertEqual(frame.cameraPosition.y, 2, accuracy: 0.001)
        XCTAssertEqual(frame.cameraPosition.z, 3, accuracy: 0.001)
    }
    
    func testFrameDataCameraForward() {
        let frame = ARFrameData(
            timestamp: 0,
            cameraTransform: matrix_identity_float4x4,
            projectionMatrix: matrix_identity_float4x4,
            lightEstimate: nil,
            trackingQuality: .normal
        )
        
        let forward = frame.cameraForward
        XCTAssertEqual(forward.z, -1, accuracy: 0.001)
    }
    
    // MARK: - Anchor Data Tests
    
    func testAnchorDataPosition() {
        let position = SIMD3<Float>(5, 6, 7)
        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4<Float>(position, 1)
        
        let anchor = ARAnchorData(
            transform: transform,
            type: .world
        )
        
        XCTAssertEqual(anchor.position.x, 5, accuracy: 0.001)
        XCTAssertEqual(anchor.position.y, 6, accuracy: 0.001)
        XCTAssertEqual(anchor.position.z, 7, accuracy: 0.001)
    }
    
    func testAnchorDataIdentifiable() {
        let anchor1 = ARAnchorData(transform: matrix_identity_float4x4, type: .world)
        let anchor2 = ARAnchorData(transform: matrix_identity_float4x4, type: .world)
        
        XCTAssertNotEqual(anchor1.id, anchor2.id)
    }
    
    // MARK: - Session Factory Tests
    
    @MainActor
    func testWorldTrackingSessionFactory() {
        let session = ARSessionFactory.worldTrackingSession()
        XCTAssertEqual(session.configuration.trackingMode, .world)
    }
    
    @MainActor
    func testImageTrackingSessionFactory() {
        let session = ARSessionFactory.imageTrackingSession()
        XCTAssertEqual(session.configuration.trackingMode, .image)
    }
    
    @MainActor
    func testFaceTrackingSessionFactory() {
        let session = ARSessionFactory.faceTrackingSession()
        XCTAssertEqual(session.configuration.trackingMode, .face)
    }
    
    @MainActor
    func testLightweightSessionFactory() {
        let session = ARSessionFactory.lightweightSession()
        XCTAssertEqual(session.configuration.trackingMode, .world)
        XCTAssertTrue(session.configuration.planeDetection.isEmpty)
    }
    
    // MARK: - Anchor Type Tests
    
    func testAnchorTypeCases() {
        let allCases = ARAnchorType.allCases
        XCTAssertTrue(allCases.contains(.world))
        XCTAssertTrue(allCases.contains(.plane))
        XCTAssertTrue(allCases.contains(.image))
        XCTAssertTrue(allCases.contains(.object))
        XCTAssertTrue(allCases.contains(.face))
        XCTAssertTrue(allCases.contains(.body))
        XCTAssertTrue(allCases.contains(.hand))
        XCTAssertTrue(allCases.contains(.custom))
    }
}

// MARK: - Configuration Tests

final class ARConfigurationTests: XCTestCase {
    
    func testDefaultConfiguration() {
        let config = ARCraftConfiguration.default
        
        XCTAssertEqual(config.trackingMode, .world)
        XCTAssertFalse(config.planeDetection.isEmpty)
        XCTAssertEqual(config.worldAlignment, .gravity)
        XCTAssertEqual(config.environmentTexturing, .automatic)
        XCTAssertEqual(config.targetFrameRate, 60)
    }
    
    func testPerformanceConfiguration() {
        let config = ARCraftConfiguration.performance
        
        XCTAssertEqual(config.environmentTexturing, .none)
        XCTAssertEqual(config.lightEstimation, .ambientIntensity)
        XCTAssertTrue(config.reducedProcessing)
    }
    
    func testQualityConfiguration() {
        let config = ARCraftConfiguration.quality
        
        XCTAssertEqual(config.environmentTexturing, .automatic)
        XCTAssertEqual(config.lightEstimation, .environmentalHDR)
        XCTAssertTrue(config.highResolutionFrames)
    }
    
    func testConfigurationCopy() {
        let original = ARCraftConfiguration()
        original.trackingMode = .face
        original.targetFrameRate = 30
        
        let copy = original.copy()
        
        XCTAssertEqual(copy.trackingMode, .face)
        XCTAssertEqual(copy.targetFrameRate, 30)
    }
    
    func testConfigurationValidation() {
        let config = ARCraftConfiguration()
        config.targetFrameRate = 200 // Invalid
        config.maximumTrackedImages = -1 // Invalid
        
        let errors = config.validate()
        
        XCTAssertFalse(errors.isEmpty)
    }
    
    func testPlaneDetectionOptions() {
        let horizontal = PlaneDetectionOptions.horizontal
        let vertical = PlaneDetectionOptions.vertical
        let all: PlaneDetectionOptions = [.horizontal, .vertical]
        
        XCTAssertTrue(all.contains(.horizontal))
        XCTAssertTrue(all.contains(.vertical))
        XCTAssertFalse(horizontal.contains(.vertical))
    }
    
    func testTrackingModeMinimumVersion() {
        XCTAssertEqual(ARTrackingMode.world.minimumIOSVersion, 11.0)
        XCTAssertEqual(ARTrackingMode.image.minimumIOSVersion, 11.3)
        XCTAssertEqual(ARTrackingMode.body.minimumIOSVersion, 13.0)
    }
    
    func testVideoFormatPresets() {
        let hd720 = ARVideoFormat.hd720p30
        let hd1080 = ARVideoFormat.hd1080p60
        let uhd4k = ARVideoFormat.uhd4K30
        
        XCTAssertEqual(hd720.width, 1280)
        XCTAssertEqual(hd720.height, 720)
        XCTAssertEqual(hd720.framesPerSecond, 30)
        
        XCTAssertEqual(hd1080.width, 1920)
        XCTAssertEqual(hd1080.framesPerSecond, 60)
        
        XCTAssertEqual(uhd4k.pixelCount, 3840 * 2160)
    }
    
    func testReferenceImageEquality() {
        let ref1 = ARReferenceImage(name: "poster", physicalWidth: 0.3)
        let ref2 = ARReferenceImage(name: "poster", physicalWidth: 0.3)
        
        XCTAssertNotEqual(ref1, ref2) // Different UUIDs
        XCTAssertEqual(ref1, ref1) // Same instance
    }
}
