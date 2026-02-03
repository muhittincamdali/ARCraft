//
//  TapGesture.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Tap Result

/// Result of a tap gesture in AR space.
public struct TapResult: Sendable {
    /// Screen location of the tap
    public let screenLocation: CGPoint
    
    /// World position (if hit detected)
    public let worldPosition: SIMD3<Float>?
    
    /// Entity that was tapped (if any)
    public let entityID: UUID?
    
    /// Anchor that was tapped (if any)
    public let anchorID: UUID?
    
    /// Surface normal at tap point
    public let surfaceNormal: SIMD3<Float>?
    
    /// Distance from camera
    public let distance: Float?
    
    /// Timestamp of the tap
    public let timestamp: TimeInterval
    
    /// Whether a surface was hit
    public var didHitSurface: Bool {
        worldPosition != nil
    }
    
    /// Whether an entity was tapped
    public var didHitEntity: Bool {
        entityID != nil
    }
    
    /// Creates a tap result
    public init(
        screenLocation: CGPoint,
        worldPosition: SIMD3<Float>? = nil,
        entityID: UUID? = nil,
        anchorID: UUID? = nil,
        surfaceNormal: SIMD3<Float>? = nil,
        distance: Float? = nil,
        timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        self.screenLocation = screenLocation
        self.worldPosition = worldPosition
        self.entityID = entityID
        self.anchorID = anchorID
        self.surfaceNormal = surfaceNormal
        self.distance = distance
        self.timestamp = timestamp
    }
}

// MARK: - Tap Handler

/// Handler for tap gestures in AR.
///
/// `TapHandler` processes tap gestures and performs raycasts
/// to determine what was tapped in the AR scene.
public final class TapHandler: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Whether tap handling is enabled
    public var isEnabled: Bool = true
    
    /// Maximum tap duration
    public var maxTapDuration: TimeInterval = 0.3
    
    /// Maximum movement for a tap
    public var maxTapMovement: Float = 10
    
    /// Whether to raycast on tap
    public var performRaycast: Bool = true
    
    /// Callback for tap events
    public var onTap: ((TapResult) -> Void)?
    
    /// Callback for double tap events
    public var onDoubleTap: ((TapResult) -> Void)?
    
    private var tapStartLocation: CGPoint = .zero
    private var tapStartTime: TimeInterval = 0
    private var lastTapTime: TimeInterval = 0
    private var lastTapLocation: CGPoint = .zero
    
    // MARK: - Initialization
    
    /// Creates a tap handler
    public init() {}
    
    // MARK: - Processing
    
    /// Processes a potential tap start
    public func tapBegan(at location: CGPoint) {
        guard isEnabled else { return }
        
        tapStartLocation = location
        tapStartTime = ProcessInfo.processInfo.systemUptime
    }
    
    /// Processes a potential tap end
    public func tapEnded(at location: CGPoint) {
        guard isEnabled else { return }
        
        let currentTime = ProcessInfo.processInfo.systemUptime
        let duration = currentTime - tapStartTime
        let movement = distance(tapStartLocation, location)
        
        guard duration <= maxTapDuration && movement <= maxTapMovement else {
            return
        }
        
        // Check for double tap
        let timeSinceLastTap = currentTime - lastTapTime
        let distanceFromLastTap = distance(lastTapLocation, location)
        
        if timeSinceLastTap < 0.3 && distanceFromLastTap < 30 {
            handleDoubleTap(at: location)
        } else {
            handleTap(at: location)
        }
        
        lastTapTime = currentTime
        lastTapLocation = location
    }
    
    /// Cancels the current tap
    public func tapCancelled() {
        tapStartTime = 0
    }
    
    // MARK: - Handling
    
    private func handleTap(at location: CGPoint) {
        let result = TapResult(screenLocation: location)
        onTap?(result)
    }
    
    private func handleDoubleTap(at location: CGPoint) {
        let result = TapResult(screenLocation: location)
        onDoubleTap?(result)
    }
    
    // MARK: - Utility
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> Float {
        let dx = Float(p2.x - p1.x)
        let dy = Float(p2.y - p1.y)
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Tap Gesture Recognizer

/// Recognizes tap gestures for AR views.
public final class ARTapGestureRecognizer: @unchecked Sendable {
    
    /// Number of taps required
    public var numberOfTapsRequired: Int = 1
    
    /// Number of touches required
    public var numberOfTouchesRequired: Int = 1
    
    /// Action to perform on tap
    public var action: ((CGPoint) -> Void)?
    
    /// Whether the recognizer is enabled
    public var isEnabled: Bool = true
    
    private var tapCount: Int = 0
    private var lastTapTime: TimeInterval = 0
    
    /// Creates a recognizer
    public init(taps: Int = 1, touches: Int = 1) {
        self.numberOfTapsRequired = taps
        self.numberOfTouchesRequired = touches
    }
    
    /// Processes a tap at location
    public func processTap(at location: CGPoint, touchCount: Int) {
        guard isEnabled else { return }
        guard touchCount == numberOfTouchesRequired else { return }
        
        let currentTime = ProcessInfo.processInfo.systemUptime
        
        if currentTime - lastTapTime > 0.4 {
            tapCount = 0
        }
        
        tapCount += 1
        lastTapTime = currentTime
        
        if tapCount >= numberOfTapsRequired {
            action?(location)
            tapCount = 0
        }
    }
    
    /// Resets the recognizer
    public func reset() {
        tapCount = 0
        lastTapTime = 0
    }
}
