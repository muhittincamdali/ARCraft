//
//  GestureHandler.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import Combine
import simd

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Gesture Type

/// Types of gestures that can be recognized.
public enum GestureType: String, Sendable, CaseIterable {
    case tap
    case doubleTap
    case longPress
    case pan
    case pinch
    case rotation
    case swipe
    case drag
    
    /// Description
    public var description: String {
        switch self {
        case .tap: return "Tap"
        case .doubleTap: return "Double Tap"
        case .longPress: return "Long Press"
        case .pan: return "Pan"
        case .pinch: return "Pinch"
        case .rotation: return "Rotation"
        case .swipe: return "Swipe"
        case .drag: return "Drag"
        }
    }
}

// MARK: - Gesture State

/// State of a gesture recognizer.
public enum GestureState: String, Sendable, Equatable {
    case possible
    case began
    case changed
    case ended
    case cancelled
    case failed
    
    /// Whether the gesture is active
    public var isActive: Bool {
        self == .began || self == .changed
    }
}

// MARK: - Gesture Event

/// Event data for a gesture.
public struct GestureEvent: Sendable {
    /// Type of gesture
    public let type: GestureType
    
    /// Current state
    public let state: GestureState
    
    /// Location in view coordinates
    public let location: CGPoint
    
    /// Location in world coordinates (if available)
    public let worldLocation: SIMD3<Float>?
    
    /// Translation for pan gestures
    public let translation: CGPoint
    
    /// Velocity for pan/swipe gestures
    public let velocity: CGPoint
    
    /// Scale for pinch gestures
    public let scale: Float
    
    /// Rotation angle for rotation gestures
    public let rotation: Float
    
    /// Number of touches
    public let touchCount: Int
    
    /// Target entity (if any)
    public let targetEntityID: UUID?
    
    /// Timestamp
    public let timestamp: TimeInterval
    
    /// Creates a gesture event
    public init(
        type: GestureType,
        state: GestureState,
        location: CGPoint,
        worldLocation: SIMD3<Float>? = nil,
        translation: CGPoint = .zero,
        velocity: CGPoint = .zero,
        scale: Float = 1,
        rotation: Float = 0,
        touchCount: Int = 1,
        targetEntityID: UUID? = nil,
        timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        self.type = type
        self.state = state
        self.location = location
        self.worldLocation = worldLocation
        self.translation = translation
        self.velocity = velocity
        self.scale = scale
        self.rotation = rotation
        self.touchCount = touchCount
        self.targetEntityID = targetEntityID
        self.timestamp = timestamp
    }
}

// MARK: - Gesture Handler Delegate

/// Protocol for receiving gesture events.
public protocol GestureHandlerDelegate: AnyObject {
    /// Called when a gesture is recognized
    func gestureHandler(_ handler: GestureHandler, didRecognize event: GestureEvent)
    
    /// Called to determine if a gesture should begin
    func gestureHandler(_ handler: GestureHandler, shouldBegin type: GestureType) -> Bool
    
    /// Called when gestures should be recognized simultaneously
    func gestureHandler(_ handler: GestureHandler, shouldRecognizeSimultaneously type1: GestureType, with type2: GestureType) -> Bool
}

public extension GestureHandlerDelegate {
    func gestureHandler(_ handler: GestureHandler, shouldBegin type: GestureType) -> Bool { true }
    func gestureHandler(_ handler: GestureHandler, shouldRecognizeSimultaneously type1: GestureType, with type2: GestureType) -> Bool { false }
}

// MARK: - Gesture Configuration

/// Configuration for gesture recognition.
public struct GestureConfiguration: Sendable {
    /// Enabled gesture types
    public var enabledGestures: Set<GestureType>
    
    /// Minimum tap duration
    public var minimumTapDuration: TimeInterval
    
    /// Maximum tap duration
    public var maximumTapDuration: TimeInterval
    
    /// Long press duration
    public var longPressDuration: TimeInterval
    
    /// Maximum tap movement
    public var maximumTapMovement: Float
    
    /// Minimum pinch scale change
    public var minimumPinchScale: Float
    
    /// Minimum rotation angle change
    public var minimumRotationAngle: Float
    
    /// Swipe minimum velocity
    public var swipeMinimumVelocity: Float
    
    /// Double tap maximum interval
    public var doubleTapMaxInterval: TimeInterval
    
    /// Creates default configuration
    public init() {
        self.enabledGestures = Set(GestureType.allCases)
        self.minimumTapDuration = 0.0
        self.maximumTapDuration = 0.3
        self.longPressDuration = 0.5
        self.maximumTapMovement = 10
        self.minimumPinchScale = 0.05
        self.minimumRotationAngle = 0.1
        self.swipeMinimumVelocity = 300
        self.doubleTapMaxInterval = 0.3
    }
    
    /// Configuration for all gestures
    public static var all: GestureConfiguration {
        GestureConfiguration()
    }
    
    /// Configuration for basic gestures only
    public static var basic: GestureConfiguration {
        var config = GestureConfiguration()
        config.enabledGestures = [.tap, .pan]
        return config
    }
    
    /// Configuration for manipulation gestures
    public static var manipulation: GestureConfiguration {
        var config = GestureConfiguration()
        config.enabledGestures = [.tap, .pan, .pinch, .rotation]
        return config
    }
}

// MARK: - Touch Point

/// Represents a touch point.
public struct TouchPoint: Sendable {
    /// Touch identifier
    public let id: Int
    
    /// Current location
    public var location: CGPoint
    
    /// Previous location
    public var previousLocation: CGPoint
    
    /// Start location
    public let startLocation: CGPoint
    
    /// Start time
    public let startTime: TimeInterval
    
    /// Current phase
    public var phase: TouchPhase
    
    /// Touch phase
    public enum TouchPhase: String, Sendable {
        case began
        case moved
        case stationary
        case ended
        case cancelled
    }
    
    /// Creates a touch point
    public init(
        id: Int,
        location: CGPoint,
        phase: TouchPhase
    ) {
        self.id = id
        self.location = location
        self.previousLocation = location
        self.startLocation = location
        self.startTime = ProcessInfo.processInfo.systemUptime
        self.phase = phase
    }
    
    /// Distance moved from start
    public var distanceFromStart: Float {
        let dx = Float(location.x - startLocation.x)
        let dy = Float(location.y - startLocation.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Duration since touch began
    public var duration: TimeInterval {
        ProcessInfo.processInfo.systemUptime - startTime
    }
}

// MARK: - Gesture Handler

/// Handles gesture recognition for AR interactions.
///
/// `GestureHandler` provides a unified interface for recognizing
/// various gesture types and translating them into AR interactions.
///
/// ## Example
///
/// ```swift
/// let handler = GestureHandler()
/// handler.delegate = self
/// handler.configuration.enabledGestures = [.tap, .pan, .pinch]
///
/// // In delegate
/// func gestureHandler(_ handler: GestureHandler, didRecognize event: GestureEvent) {
///     switch event.type {
///     case .tap:
///         handleTap(at: event.location)
///     case .pan:
///         handlePan(translation: event.translation)
///     default:
///         break
///     }
/// }
/// ```
public final class GestureHandler: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Delegate for receiving events
    public weak var delegate: GestureHandlerDelegate?
    
    /// Publisher for gesture events
    public let eventPublisher = PassthroughSubject<GestureEvent, Never>()
    
    /// Configuration
    public var configuration: GestureConfiguration
    
    /// Whether gesture recognition is enabled
    public var isEnabled: Bool = true
    
    /// Active touches
    private var activeTouches: [Int: TouchPoint] = [:]
    
    /// Last tap timestamp (for double tap)
    private var lastTapTimestamp: TimeInterval = 0
    
    /// Last tap location (for double tap)
    private var lastTapLocation: CGPoint = .zero
    
    /// Pan start location
    private var panStartLocation: CGPoint = .zero
    
    /// Initial pinch distance
    private var initialPinchDistance: Float = 0
    
    /// Initial rotation angle
    private var initialRotationAngle: Float = 0
    
    /// Current gesture state
    private var currentGestureState: [GestureType: GestureState] = [:]
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a gesture handler with configuration.
    public init(configuration: GestureConfiguration = .all) {
        self.configuration = configuration
    }
    
    // MARK: - Touch Handling
    
    /// Handles touch began event.
    public func touchesBegan(_ touches: [TouchPoint]) {
        guard isEnabled else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        for touch in touches {
            activeTouches[touch.id] = touch
        }
        
        processGestures()
    }
    
    /// Handles touch moved event.
    public func touchesMoved(_ touches: [TouchPoint]) {
        guard isEnabled else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        for touch in touches {
            if var existing = activeTouches[touch.id] {
                existing.previousLocation = existing.location
                existing.location = touch.location
                existing.phase = .moved
                activeTouches[touch.id] = existing
            }
        }
        
        processGestures()
    }
    
    /// Handles touch ended event.
    public func touchesEnded(_ touches: [TouchPoint]) {
        guard isEnabled else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        for touch in touches {
            if var existing = activeTouches[touch.id] {
                existing.phase = .ended
                activeTouches[touch.id] = existing
            }
        }
        
        processGestures()
        
        // Remove ended touches
        for touch in touches {
            activeTouches.removeValue(forKey: touch.id)
        }
    }
    
    /// Handles touch cancelled event.
    public func touchesCancelled(_ touches: [TouchPoint]) {
        lock.lock()
        defer { lock.unlock() }
        
        for touch in touches {
            activeTouches.removeValue(forKey: touch.id)
        }
        
        cancelAllGestures()
    }
    
    // MARK: - Gesture Processing
    
    private func processGestures() {
        let touchCount = activeTouches.count
        let touches = Array(activeTouches.values)
        
        guard !touches.isEmpty else { return }
        
        // Single touch gestures
        if touchCount == 1, let touch = touches.first {
            processSingleTouchGestures(touch)
        }
        
        // Two touch gestures
        if touchCount == 2 {
            processTwoTouchGestures(touches[0], touches[1])
        }
    }
    
    private func processSingleTouchGestures(_ touch: TouchPoint) {
        switch touch.phase {
        case .began:
            // Potential tap or pan starting
            panStartLocation = touch.location
            
        case .moved:
            // Check for pan
            if touch.distanceFromStart > configuration.maximumTapMovement {
                if configuration.enabledGestures.contains(.pan) {
                    recognizePan(touch)
                }
            }
            
        case .ended:
            // Check for tap
            if touch.distanceFromStart <= configuration.maximumTapMovement &&
               touch.duration <= configuration.maximumTapDuration {
                
                // Check for double tap
                let now = ProcessInfo.processInfo.systemUptime
                if now - lastTapTimestamp <= configuration.doubleTapMaxInterval &&
                   distance(touch.location, lastTapLocation) < 30 {
                    recognizeDoubleTap(touch)
                } else if configuration.enabledGestures.contains(.tap) {
                    recognizeTap(touch)
                }
                
                lastTapTimestamp = now
                lastTapLocation = touch.location
            }
            
            // End pan if active
            if currentGestureState[.pan] == .changed {
                endPan(touch)
            }
            
        case .stationary:
            // Check for long press
            if touch.duration >= configuration.longPressDuration &&
               touch.distanceFromStart <= configuration.maximumTapMovement &&
               configuration.enabledGestures.contains(.longPress) {
                recognizeLongPress(touch)
            }
            
        case .cancelled:
            cancelAllGestures()
        }
    }
    
    private func processTwoTouchGestures(_ touch1: TouchPoint, _ touch2: TouchPoint) {
        // Pinch
        if configuration.enabledGestures.contains(.pinch) {
            recognizePinch(touch1, touch2)
        }
        
        // Rotation
        if configuration.enabledGestures.contains(.rotation) {
            recognizeRotation(touch1, touch2)
        }
    }
    
    // MARK: - Gesture Recognition
    
    private func recognizeTap(_ touch: TouchPoint) {
        let event = GestureEvent(
            type: .tap,
            state: .ended,
            location: touch.location,
            touchCount: 1
        )
        sendEvent(event)
    }
    
    private func recognizeDoubleTap(_ touch: TouchPoint) {
        let event = GestureEvent(
            type: .doubleTap,
            state: .ended,
            location: touch.location,
            touchCount: 1
        )
        sendEvent(event)
    }
    
    private func recognizeLongPress(_ touch: TouchPoint) {
        let event = GestureEvent(
            type: .longPress,
            state: .ended,
            location: touch.location,
            touchCount: 1
        )
        sendEvent(event)
    }
    
    private func recognizePan(_ touch: TouchPoint) {
        let translation = CGPoint(
            x: touch.location.x - panStartLocation.x,
            y: touch.location.y - panStartLocation.y
        )
        
        let velocity = CGPoint(
            x: touch.location.x - touch.previousLocation.x,
            y: touch.location.y - touch.previousLocation.y
        )
        
        let state: GestureState
        if currentGestureState[.pan] != .changed {
            state = .began
            currentGestureState[.pan] = .began
        } else {
            state = .changed
        }
        
        let event = GestureEvent(
            type: .pan,
            state: state,
            location: touch.location,
            translation: translation,
            velocity: velocity,
            touchCount: 1
        )
        sendEvent(event)
        currentGestureState[.pan] = .changed
    }
    
    private func endPan(_ touch: TouchPoint) {
        let translation = CGPoint(
            x: touch.location.x - panStartLocation.x,
            y: touch.location.y - panStartLocation.y
        )
        
        let event = GestureEvent(
            type: .pan,
            state: .ended,
            location: touch.location,
            translation: translation,
            touchCount: 1
        )
        sendEvent(event)
        currentGestureState[.pan] = .ended
    }
    
    private func recognizePinch(_ touch1: TouchPoint, _ touch2: TouchPoint) {
        let currentDistance = distance(touch1.location, touch2.location)
        let center = CGPoint(
            x: (touch1.location.x + touch2.location.x) / 2,
            y: (touch1.location.y + touch2.location.y) / 2
        )
        
        if initialPinchDistance == 0 {
            initialPinchDistance = currentDistance
        }
        
        let scale = currentDistance / initialPinchDistance
        
        if abs(scale - 1) < configuration.minimumPinchScale {
            return
        }
        
        let state: GestureState
        if currentGestureState[.pinch] != .changed {
            state = .began
        } else {
            state = .changed
        }
        
        let event = GestureEvent(
            type: .pinch,
            state: state,
            location: center,
            scale: scale,
            touchCount: 2
        )
        sendEvent(event)
        currentGestureState[.pinch] = .changed
    }
    
    private func recognizeRotation(_ touch1: TouchPoint, _ touch2: TouchPoint) {
        let currentAngle = atan2(
            Float(touch2.location.y - touch1.location.y),
            Float(touch2.location.x - touch1.location.x)
        )
        
        if initialRotationAngle == 0 {
            initialRotationAngle = currentAngle
        }
        
        let rotation = currentAngle - initialRotationAngle
        
        if abs(rotation) < configuration.minimumRotationAngle {
            return
        }
        
        let center = CGPoint(
            x: (touch1.location.x + touch2.location.x) / 2,
            y: (touch1.location.y + touch2.location.y) / 2
        )
        
        let state: GestureState
        if currentGestureState[.rotation] != .changed {
            state = .began
        } else {
            state = .changed
        }
        
        let event = GestureEvent(
            type: .rotation,
            state: state,
            location: center,
            rotation: rotation,
            touchCount: 2
        )
        sendEvent(event)
        currentGestureState[.rotation] = .changed
    }
    
    private func cancelAllGestures() {
        for (type, state) in currentGestureState where state.isActive {
            let event = GestureEvent(
                type: type,
                state: .cancelled,
                location: .zero
            )
            sendEvent(event)
        }
        currentGestureState.removeAll()
        initialPinchDistance = 0
        initialRotationAngle = 0
    }
    
    // MARK: - Event Dispatch
    
    private func sendEvent(_ event: GestureEvent) {
        eventPublisher.send(event)
        delegate?.gestureHandler(self, didRecognize: event)
    }
    
    // MARK: - Utility
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> Float {
        let dx = Float(p2.x - p1.x)
        let dy = Float(p2.y - p1.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Resets the gesture handler state.
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        
        activeTouches.removeAll()
        currentGestureState.removeAll()
        initialPinchDistance = 0
        initialRotationAngle = 0
        lastTapTimestamp = 0
    }
}
