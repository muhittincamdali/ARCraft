//
//  AnimationController.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Animation State

/// State of an animation.
public enum AnimationState: String, Sendable, Equatable {
    /// Animation is stopped
    case stopped
    
    /// Animation is playing
    case playing
    
    /// Animation is paused
    case paused
    
    /// Animation has completed
    case completed
}

// MARK: - Easing Function

/// Easing functions for animations.
public enum EasingFunction: String, Sendable, CaseIterable {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case easeInQuad
    case easeOutQuad
    case easeInOutQuad
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic
    case easeInExpo
    case easeOutExpo
    case easeInOutExpo
    case easeInBack
    case easeOutBack
    case easeInOutBack
    case easeInElastic
    case easeOutElastic
    case easeInOutElastic
    case easeInBounce
    case easeOutBounce
    case easeInOutBounce
    
    /// Evaluates the easing function
    public func evaluate(_ t: Float) -> Float {
        switch self {
        case .linear:
            return t
            
        case .easeIn:
            return t * t * t
            
        case .easeOut:
            return 1 - pow(1 - t, 3)
            
        case .easeInOut:
            return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
            
        case .easeInQuad:
            return t * t
            
        case .easeOutQuad:
            return 1 - (1 - t) * (1 - t)
            
        case .easeInOutQuad:
            return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
            
        case .easeInCubic:
            return t * t * t
            
        case .easeOutCubic:
            return 1 - pow(1 - t, 3)
            
        case .easeInOutCubic:
            return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
            
        case .easeInExpo:
            return t == 0 ? 0 : pow(2, 10 * t - 10)
            
        case .easeOutExpo:
            return t == 1 ? 1 : 1 - pow(2, -10 * t)
            
        case .easeInOutExpo:
            if t == 0 { return 0 }
            if t == 1 { return 1 }
            return t < 0.5 ? pow(2, 20 * t - 10) / 2 : (2 - pow(2, -20 * t + 10)) / 2
            
        case .easeInBack:
            let c1: Float = 1.70158
            let c3 = c1 + 1
            return c3 * t * t * t - c1 * t * t
            
        case .easeOutBack:
            let c1: Float = 1.70158
            let c3 = c1 + 1
            return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2)
            
        case .easeInOutBack:
            let c1: Float = 1.70158
            let c2 = c1 * 1.525
            return t < 0.5
                ? (pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2
                : (pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
            
        case .easeInElastic:
            let c4 = (2 * .pi) / 3
            if t == 0 { return 0 }
            if t == 1 { return 1 }
            return -pow(2, 10 * t - 10) * sin((t * 10 - 10.75) * c4)
            
        case .easeOutElastic:
            let c4 = (2 * .pi) / 3
            if t == 0 { return 0 }
            if t == 1 { return 1 }
            return pow(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1
            
        case .easeInOutElastic:
            let c5 = (2 * .pi) / 4.5
            if t == 0 { return 0 }
            if t == 1 { return 1 }
            return t < 0.5
                ? -(pow(2, 20 * t - 10) * sin((20 * t - 11.125) * c5)) / 2
                : (pow(2, -20 * t + 10) * sin((20 * t - 11.125) * c5)) / 2 + 1
            
        case .easeInBounce:
            return 1 - EasingFunction.easeOutBounce.evaluate(1 - t)
            
        case .easeOutBounce:
            let n1: Float = 7.5625
            let d1: Float = 2.75
            var t = t
            
            if t < 1 / d1 {
                return n1 * t * t
            } else if t < 2 / d1 {
                t -= 1.5 / d1
                return n1 * t * t + 0.75
            } else if t < 2.5 / d1 {
                t -= 2.25 / d1
                return n1 * t * t + 0.9375
            } else {
                t -= 2.625 / d1
                return n1 * t * t + 0.984375
            }
            
        case .easeInOutBounce:
            return t < 0.5
                ? (1 - EasingFunction.easeOutBounce.evaluate(1 - 2 * t)) / 2
                : (1 + EasingFunction.easeOutBounce.evaluate(2 * t - 1)) / 2
        }
    }
}

// MARK: - Animation

/// A single animation.
public final class Animation: Identifiable, @unchecked Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Name of the animation
    public var name: String
    
    /// Duration in seconds
    public var duration: TimeInterval
    
    /// Current state
    public private(set) var state: AnimationState
    
    /// Current time
    public private(set) var currentTime: TimeInterval
    
    /// Easing function
    public var easing: EasingFunction
    
    /// Whether the animation loops
    public var loops: Bool
    
    /// Number of times to loop (0 = infinite)
    public var loopCount: Int
    
    /// Current loop iteration
    public private(set) var currentLoop: Int
    
    /// Whether the animation plays in reverse after completing
    public var autoReverse: Bool
    
    /// Whether currently in reverse
    public private(set) var isReversing: Bool
    
    /// Playback speed multiplier
    public var speed: Float
    
    /// Delay before starting
    public var delay: TimeInterval
    
    /// Remaining delay
    private var remainingDelay: TimeInterval
    
    /// Target entity
    public weak var entity: ARCraftEntity?
    
    /// Completion callback
    public var onComplete: (() -> Void)?
    
    /// Update callback (receives normalized progress 0-1)
    public var onUpdate: ((Float) -> Void)?
    
    private let lock = NSLock()
    
    /// Creates an animation
    public init(
        name: String = "Animation",
        duration: TimeInterval,
        easing: EasingFunction = .easeInOut
    ) {
        self.id = UUID()
        self.name = name
        self.duration = duration
        self.state = .stopped
        self.currentTime = 0
        self.easing = easing
        self.loops = false
        self.loopCount = 0
        self.currentLoop = 0
        self.autoReverse = false
        self.isReversing = false
        self.speed = 1.0
        self.delay = 0
        self.remainingDelay = 0
    }
    
    /// Starts the animation
    public func play() {
        lock.lock()
        defer { lock.unlock() }
        
        if state == .stopped {
            currentTime = 0
            currentLoop = 0
            isReversing = false
            remainingDelay = delay
        }
        state = .playing
    }
    
    /// Pauses the animation
    public func pause() {
        lock.lock()
        defer { lock.unlock() }
        
        if state == .playing {
            state = .paused
        }
    }
    
    /// Resumes the animation
    public func resume() {
        lock.lock()
        defer { lock.unlock() }
        
        if state == .paused {
            state = .playing
        }
    }
    
    /// Stops the animation
    public func stop() {
        lock.lock()
        defer { lock.unlock() }
        
        state = .stopped
        currentTime = 0
        currentLoop = 0
    }
    
    /// Resets the animation
    public func reset() {
        stop()
    }
    
    /// Updates the animation
    func update(deltaTime: TimeInterval) {
        lock.lock()
        defer { lock.unlock() }
        
        guard state == .playing else { return }
        
        // Handle delay
        if remainingDelay > 0 {
            remainingDelay -= deltaTime
            return
        }
        
        // Update time
        let scaledDelta = deltaTime * Double(speed)
        
        if isReversing {
            currentTime -= scaledDelta
        } else {
            currentTime += scaledDelta
        }
        
        // Check completion
        if currentTime >= duration {
            if autoReverse && !isReversing {
                isReversing = true
                currentTime = duration
            } else if loops && (loopCount == 0 || currentLoop < loopCount - 1) {
                currentLoop += 1
                currentTime = 0
                isReversing = false
            } else {
                currentTime = duration
                state = .completed
                onComplete?()
            }
        } else if isReversing && currentTime <= 0 {
            if loops && (loopCount == 0 || currentLoop < loopCount - 1) {
                currentLoop += 1
                currentTime = 0
                isReversing = false
            } else {
                currentTime = 0
                state = .completed
                onComplete?()
            }
        }
        
        // Calculate progress
        let rawProgress = Float(max(0, min(1, currentTime / duration)))
        let easedProgress = easing.evaluate(rawProgress)
        
        onUpdate?(easedProgress)
    }
    
    /// Normalized progress (0-1)
    public var progress: Float {
        Float(max(0, min(1, currentTime / duration)))
    }
    
    /// Eased progress
    public var easedProgress: Float {
        easing.evaluate(progress)
    }
}

// MARK: - Animation Controller

/// Controller for managing animations.
///
/// `AnimationController` handles the lifecycle and updates
/// of multiple animations across the scene.
///
/// ## Example
///
/// ```swift
/// let controller = AnimationController()
///
/// let fadeIn = Animation(name: "FadeIn", duration: 0.5)
/// fadeIn.onUpdate = { progress in
///     entity.opacity = progress
/// }
///
/// controller.add(fadeIn)
/// fadeIn.play()
/// ```
public final class AnimationController: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// All managed animations
    private var animations: [UUID: Animation] = [:]
    
    /// Whether updates are paused
    public var isPaused: Bool = false
    
    /// Global speed multiplier
    public var globalSpeed: Float = 1.0
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates an animation controller
    public init() {}
    
    // MARK: - Animation Management
    
    /// Adds an animation
    public func add(_ animation: Animation) {
        lock.lock()
        animations[animation.id] = animation
        lock.unlock()
    }
    
    /// Removes an animation
    public func remove(_ animation: Animation) {
        lock.lock()
        animations.removeValue(forKey: animation.id)
        lock.unlock()
    }
    
    /// Removes animation by ID
    public func remove(id: UUID) {
        lock.lock()
        animations.removeValue(forKey: id)
        lock.unlock()
    }
    
    /// Gets an animation by ID
    public func animation(id: UUID) -> Animation? {
        lock.lock()
        defer { lock.unlock() }
        return animations[id]
    }
    
    /// All animations
    public var allAnimations: [Animation] {
        lock.lock()
        defer { lock.unlock() }
        return Array(animations.values)
    }
    
    /// Playing animations
    public var playingAnimations: [Animation] {
        lock.lock()
        defer { lock.unlock() }
        return animations.values.filter { $0.state == .playing }
    }
    
    /// Number of animations
    public var animationCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return animations.count
    }
    
    // MARK: - Update
    
    /// Updates all animations
    public func update(deltaTime: TimeInterval) {
        guard !isPaused else { return }
        
        lock.lock()
        let anims = Array(animations.values)
        lock.unlock()
        
        let scaledDelta = deltaTime * Double(globalSpeed)
        
        for animation in anims {
            animation.update(deltaTime: scaledDelta)
        }
        
        // Remove completed non-looping animations
        lock.lock()
        for animation in anims where animation.state == .completed && !animation.loops {
            animations.removeValue(forKey: animation.id)
        }
        lock.unlock()
    }
    
    // MARK: - Bulk Operations
    
    /// Plays all animations
    public func playAll() {
        lock.lock()
        for animation in animations.values {
            animation.play()
        }
        lock.unlock()
    }
    
    /// Pauses all animations
    public func pauseAll() {
        lock.lock()
        for animation in animations.values {
            animation.pause()
        }
        lock.unlock()
    }
    
    /// Stops all animations
    public func stopAll() {
        lock.lock()
        for animation in animations.values {
            animation.stop()
        }
        lock.unlock()
    }
    
    /// Removes all animations
    public func removeAll() {
        lock.lock()
        animations.removeAll()
        lock.unlock()
    }
    
    // MARK: - Factory Methods
    
    /// Creates and adds a position animation
    @discardableResult
    public func animatePosition(
        of entity: ARCraftEntity,
        to position: SIMD3<Float>,
        duration: TimeInterval,
        easing: EasingFunction = .easeInOut
    ) -> Animation {
        let startPosition = entity.transform.position
        
        let animation = Animation(name: "Position", duration: duration, easing: easing)
        animation.entity = entity
        animation.onUpdate = { progress in
            entity.transform.position = mix(startPosition, position, t: progress)
        }
        
        add(animation)
        animation.play()
        return animation
    }
    
    /// Creates and adds a scale animation
    @discardableResult
    public func animateScale(
        of entity: ARCraftEntity,
        to scale: SIMD3<Float>,
        duration: TimeInterval,
        easing: EasingFunction = .easeInOut
    ) -> Animation {
        let startScale = entity.transform.scale
        
        let animation = Animation(name: "Scale", duration: duration, easing: easing)
        animation.entity = entity
        animation.onUpdate = { progress in
            entity.transform.scale = mix(startScale, scale, t: progress)
        }
        
        add(animation)
        animation.play()
        return animation
    }
    
    /// Creates and adds a rotation animation
    @discardableResult
    public func animateRotation(
        of entity: ARCraftEntity,
        to rotation: simd_quatf,
        duration: TimeInterval,
        easing: EasingFunction = .easeInOut
    ) -> Animation {
        let startRotation = entity.transform.rotation
        
        let animation = Animation(name: "Rotation", duration: duration, easing: easing)
        animation.entity = entity
        animation.onUpdate = { progress in
            entity.transform.rotation = simd_slerp(startRotation, rotation, progress)
        }
        
        add(animation)
        animation.play()
        return animation
    }
}

// MARK: - Animation Sequence

/// A sequence of animations that play one after another.
public final class AnimationSequence: @unchecked Sendable {
    /// Animations in the sequence
    private var animations: [Animation] = []
    
    /// Current index
    private var currentIndex: Int = 0
    
    /// Whether the sequence loops
    public var loops: Bool = false
    
    /// Completion callback
    public var onComplete: (() -> Void)?
    
    /// Creates a sequence
    public init() {}
    
    /// Adds an animation to the sequence
    public func append(_ animation: Animation) {
        animations.append(animation)
    }
    
    /// Starts the sequence
    public func play() {
        guard !animations.isEmpty else { return }
        
        currentIndex = 0
        playCurrentAnimation()
    }
    
    private func playCurrentAnimation() {
        guard currentIndex < animations.count else {
            if loops {
                currentIndex = 0
                playCurrentAnimation()
            } else {
                onComplete?()
            }
            return
        }
        
        let animation = animations[currentIndex]
        animation.onComplete = { [weak self] in
            self?.currentIndex += 1
            self?.playCurrentAnimation()
        }
        animation.play()
    }
    
    /// Stops the sequence
    public func stop() {
        for animation in animations {
            animation.stop()
        }
        currentIndex = 0
    }
}
