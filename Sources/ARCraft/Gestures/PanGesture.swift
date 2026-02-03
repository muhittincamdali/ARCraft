//
//  PanGesture.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Pan State

/// State information for a pan gesture.
public struct PanState: Sendable {
    /// Current screen location
    public let location: CGPoint
    
    /// Translation from start
    public let translation: CGPoint
    
    /// Current velocity
    public let velocity: CGPoint
    
    /// World translation (if available)
    public let worldTranslation: SIMD3<Float>?
    
    /// Gesture state
    public let state: GestureState
    
    /// Entity being dragged (if any)
    public let targetEntityID: UUID?
    
    /// Start location
    public let startLocation: CGPoint
    
    /// Duration of the pan
    public let duration: TimeInterval
    
    /// Creates pan state
    public init(
        location: CGPoint,
        translation: CGPoint,
        velocity: CGPoint,
        worldTranslation: SIMD3<Float>? = nil,
        state: GestureState,
        targetEntityID: UUID? = nil,
        startLocation: CGPoint,
        duration: TimeInterval
    ) {
        self.location = location
        self.translation = translation
        self.velocity = velocity
        self.worldTranslation = worldTranslation
        self.state = state
        self.targetEntityID = targetEntityID
        self.startLocation = startLocation
        self.duration = duration
    }
    
    /// Whether the pan is active
    public var isActive: Bool {
        state == .began || state == .changed
    }
    
    /// Total distance moved
    public var distance: Float {
        let dx = Float(translation.x)
        let dy = Float(translation.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Direction of the pan (radians)
    public var direction: Float {
        atan2(Float(translation.y), Float(translation.x))
    }
    
    /// Speed magnitude
    public var speed: Float {
        let vx = Float(velocity.x)
        let vy = Float(velocity.y)
        return sqrt(vx * vx + vy * vy)
    }
}

// MARK: - Pan Mode

/// Mode for interpreting pan gestures.
public enum PanMode: String, Sendable, CaseIterable {
    /// Free movement in screen space
    case freeform
    
    /// Constrained to horizontal axis
    case horizontal
    
    /// Constrained to vertical axis
    case vertical
    
    /// Orbit around a point
    case orbit
    
    /// Translate on a plane
    case planar
    
    /// Description
    public var description: String {
        rawValue.capitalized
    }
}

// MARK: - Pan Handler

/// Handler for pan gestures in AR.
///
/// `PanHandler` processes continuous pan gestures and translates
/// them into AR interactions like object movement or camera orbit.
///
/// ## Example
///
/// ```swift
/// let handler = PanHandler()
/// handler.mode = .planar
/// handler.onPan = { state in
///     if let worldTranslation = state.worldTranslation {
///         selectedEntity.transform.position += worldTranslation
///     }
/// }
/// ```
public final class PanHandler: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Whether pan handling is enabled
    public var isEnabled: Bool = true
    
    /// Pan mode
    public var mode: PanMode = .freeform
    
    /// Sensitivity multiplier
    public var sensitivity: Float = 1.0
    
    /// Minimum distance to start panning
    public var minimumDistance: Float = 5
    
    /// Whether to use momentum after pan ends
    public var useMomentum: Bool = true
    
    /// Momentum decay rate
    public var momentumDecay: Float = 0.95
    
    /// Callback for pan state changes
    public var onPan: ((PanState) -> Void)?
    
    /// Callback for pan momentum
    public var onMomentum: ((CGPoint) -> Void)?
    
    private var startLocation: CGPoint = .zero
    private var previousLocation: CGPoint = .zero
    private var startTime: TimeInterval = 0
    private var currentVelocity: CGPoint = .zero
    private var isPanning: Bool = false
    private var targetEntityID: UUID?
    
    private var velocityHistory: [(CGPoint, TimeInterval)] = []
    private let maxVelocityHistoryCount = 5
    
    // MARK: - Initialization
    
    /// Creates a pan handler
    public init(mode: PanMode = .freeform) {
        self.mode = mode
    }
    
    // MARK: - Processing
    
    /// Processes pan start
    public func panBegan(at location: CGPoint, targetEntity: UUID? = nil) {
        guard isEnabled else { return }
        
        startLocation = location
        previousLocation = location
        startTime = ProcessInfo.processInfo.systemUptime
        currentVelocity = .zero
        isPanning = false
        targetEntityID = targetEntity
        velocityHistory.removeAll()
    }
    
    /// Processes pan movement
    public func panChanged(at location: CGPoint) {
        guard isEnabled else { return }
        
        let translation = applyModeConstraints(CGPoint(
            x: location.x - startLocation.x,
            y: location.y - startLocation.y
        ))
        
        let delta = CGPoint(
            x: location.x - previousLocation.x,
            y: location.y - previousLocation.y
        )
        
        // Calculate velocity
        let currentTime = ProcessInfo.processInfo.systemUptime
        velocityHistory.append((delta, currentTime))
        if velocityHistory.count > maxVelocityHistoryCount {
            velocityHistory.removeFirst()
        }
        currentVelocity = calculateAverageVelocity()
        
        previousLocation = location
        
        // Check if we should start panning
        let distance = sqrt(Float(translation.x * translation.x + translation.y * translation.y))
        
        if !isPanning && distance >= minimumDistance {
            isPanning = true
            sendPanState(
                location: location,
                translation: translation,
                state: .began
            )
        } else if isPanning {
            sendPanState(
                location: location,
                translation: translation,
                state: .changed
            )
        }
    }
    
    /// Processes pan end
    public func panEnded(at location: CGPoint) {
        guard isEnabled && isPanning else { return }
        
        let translation = applyModeConstraints(CGPoint(
            x: location.x - startLocation.x,
            y: location.y - startLocation.y
        ))
        
        sendPanState(
            location: location,
            translation: translation,
            state: .ended
        )
        
        // Start momentum if enabled
        if useMomentum && currentVelocity != .zero {
            startMomentum()
        }
        
        isPanning = false
        targetEntityID = nil
    }
    
    /// Cancels the pan
    public func panCancelled() {
        guard isPanning else { return }
        
        sendPanState(
            location: previousLocation,
            translation: .zero,
            state: .cancelled
        )
        
        isPanning = false
        targetEntityID = nil
    }
    
    // MARK: - Mode Constraints
    
    private func applyModeConstraints(_ translation: CGPoint) -> CGPoint {
        switch mode {
        case .freeform:
            return translation
            
        case .horizontal:
            return CGPoint(x: translation.x, y: 0)
            
        case .vertical:
            return CGPoint(x: 0, y: translation.y)
            
        case .orbit, .planar:
            return translation
        }
    }
    
    // MARK: - Velocity
    
    private func calculateAverageVelocity() -> CGPoint {
        guard !velocityHistory.isEmpty else { return .zero }
        
        var totalX: CGFloat = 0
        var totalY: CGFloat = 0
        
        for (delta, _) in velocityHistory {
            totalX += delta.x
            totalY += delta.y
        }
        
        let count = CGFloat(velocityHistory.count)
        return CGPoint(x: totalX / count * 60, y: totalY / count * 60)
    }
    
    // MARK: - Momentum
    
    private func startMomentum() {
        var velocity = currentVelocity
        
        func applyMomentum() {
            velocity.x *= CGFloat(momentumDecay)
            velocity.y *= CGFloat(momentumDecay)
            
            let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            
            if speed > 1 {
                onMomentum?(velocity)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1/60) {
                    applyMomentum()
                }
            }
        }
        
        applyMomentum()
    }
    
    // MARK: - State Dispatch
    
    private func sendPanState(location: CGPoint, translation: CGPoint, state: GestureState) {
        let scaledTranslation = CGPoint(
            x: translation.x * CGFloat(sensitivity),
            y: translation.y * CGFloat(sensitivity)
        )
        
        let worldTranslation = calculateWorldTranslation(scaledTranslation)
        
        let panState = PanState(
            location: location,
            translation: scaledTranslation,
            velocity: currentVelocity,
            worldTranslation: worldTranslation,
            state: state,
            targetEntityID: targetEntityID,
            startLocation: startLocation,
            duration: ProcessInfo.processInfo.systemUptime - startTime
        )
        
        onPan?(panState)
    }
    
    private func calculateWorldTranslation(_ screenTranslation: CGPoint) -> SIMD3<Float>? {
        // Convert screen translation to world translation
        // This is a simplified version - actual implementation would use camera info
        let scale: Float = 0.001
        
        switch mode {
        case .freeform:
            return SIMD3<Float>(
                Float(screenTranslation.x) * scale,
                0,
                Float(screenTranslation.y) * scale
            )
            
        case .horizontal:
            return SIMD3<Float>(Float(screenTranslation.x) * scale, 0, 0)
            
        case .vertical:
            return SIMD3<Float>(0, Float(-screenTranslation.y) * scale, 0)
            
        case .orbit:
            return nil // Orbit returns rotation instead
            
        case .planar:
            return SIMD3<Float>(
                Float(screenTranslation.x) * scale,
                0,
                Float(screenTranslation.y) * scale
            )
        }
    }
    
    // MARK: - Reset
    
    /// Resets the handler state
    public func reset() {
        isPanning = false
        currentVelocity = .zero
        velocityHistory.removeAll()
        targetEntityID = nil
    }
}

// MARK: - Drag Handler

/// Specialized handler for drag operations.
public final class DragHandler: @unchecked Sendable {
    
    /// Entity being dragged
    public private(set) var draggedEntityID: UUID?
    
    /// Original position of dragged entity
    public private(set) var originalPosition: SIMD3<Float>?
    
    /// Constraint plane for dragging
    public var constraintPlane: PlaneAnchor?
    
    /// Height offset from plane
    public var heightOffset: Float = 0.01
    
    /// Callback when drag starts
    public var onDragStart: ((UUID, SIMD3<Float>) -> Void)?
    
    /// Callback when position updates
    public var onDragUpdate: ((UUID, SIMD3<Float>) -> Void)?
    
    /// Callback when drag ends
    public var onDragEnd: ((UUID, SIMD3<Float>) -> Void)?
    
    /// Creates a drag handler
    public init() {}
    
    /// Starts dragging an entity
    public func startDrag(entityID: UUID, position: SIMD3<Float>) {
        draggedEntityID = entityID
        originalPosition = position
        onDragStart?(entityID, position)
    }
    
    /// Updates the drag position
    public func updateDrag(to position: SIMD3<Float>) {
        guard let entityID = draggedEntityID else { return }
        
        var finalPosition = position
        
        if let plane = constraintPlane {
            finalPosition = plane.project(point: position)
            finalPosition.y += heightOffset
        }
        
        onDragUpdate?(entityID, finalPosition)
    }
    
    /// Ends the drag
    public func endDrag(at position: SIMD3<Float>) {
        guard let entityID = draggedEntityID else { return }
        
        var finalPosition = position
        
        if let plane = constraintPlane {
            finalPosition = plane.project(point: position)
            finalPosition.y += heightOffset
        }
        
        onDragEnd?(entityID, finalPosition)
        
        draggedEntityID = nil
        originalPosition = nil
    }
    
    /// Cancels the drag and returns to original position
    public func cancelDrag() {
        guard let entityID = draggedEntityID,
              let original = originalPosition else { return }
        
        onDragEnd?(entityID, original)
        
        draggedEntityID = nil
        originalPosition = nil
    }
}
