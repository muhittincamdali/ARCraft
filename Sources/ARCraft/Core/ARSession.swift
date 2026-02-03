//
//  ARSession.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import Combine
import simd

#if canImport(ARKit)
import ARKit
#endif

#if canImport(RealityKit)
import RealityKit
#endif

// MARK: - Session State

/// Represents the current state of an AR session.
///
/// Use this enumeration to track and respond to session state changes
/// throughout your AR experience lifecycle.
///
/// ```swift
/// session.$state
///     .sink { state in
///         switch state {
///         case .running:
///             print("Session is active")
///         case .paused:
///             print("Session is paused")
///         default:
///             break
///         }
///     }
/// ```
public enum ARSessionState: String, Sendable, Equatable, CaseIterable {
    /// Session has not been started yet
    case notStarted
    
    /// Session is initializing and preparing resources
    case initializing
    
    /// Session is actively running and tracking
    case running
    
    /// Session is temporarily paused
    case paused
    
    /// Session encountered an error
    case error
    
    /// Session has been stopped
    case stopped
    
    /// Human-readable description of the state
    public var description: String {
        switch self {
        case .notStarted:
            return "Not Started"
        case .initializing:
            return "Initializing"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        case .error:
            return "Error"
        case .stopped:
            return "Stopped"
        }
    }
    
    /// Whether the session is in an active state
    public var isActive: Bool {
        self == .running || self == .initializing
    }
}

// MARK: - Session Error

/// Errors that can occur during AR session operations.
///
/// Handle these errors appropriately in your application to provide
/// meaningful feedback to users.
public enum ARSessionError: Error, LocalizedError, Sendable {
    /// AR is not supported on this device
    case notSupported
    
    /// Camera access was denied
    case cameraAccessDenied
    
    /// World tracking failed
    case worldTrackingFailed(String)
    
    /// Session configuration is invalid
    case invalidConfiguration
    
    /// Session timed out during initialization
    case timeout
    
    /// Session was interrupted by another application
    case interrupted
    
    /// Sensor data is unavailable
    case sensorUnavailable
    
    /// Insufficient lighting conditions
    case insufficientLighting
    
    /// Excessive motion detected
    case excessiveMotion
    
    /// Feature tracking is limited
    case limitedTracking(ARTrackingQuality)
    
    public var errorDescription: String? {
        switch self {
        case .notSupported:
            return "AR is not supported on this device"
        case .cameraAccessDenied:
            return "Camera access is required for AR experiences"
        case .worldTrackingFailed(let reason):
            return "World tracking failed: \(reason)"
        case .invalidConfiguration:
            return "Invalid session configuration"
        case .timeout:
            return "Session initialization timed out"
        case .interrupted:
            return "Session was interrupted"
        case .sensorUnavailable:
            return "Required sensors are unavailable"
        case .insufficientLighting:
            return "Lighting conditions are insufficient"
        case .excessiveMotion:
            return "Device motion is too excessive"
        case .limitedTracking(let quality):
            return "Tracking quality is limited: \(quality.description)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .notSupported:
            return "Use a device that supports AR"
        case .cameraAccessDenied:
            return "Enable camera access in Settings"
        case .worldTrackingFailed:
            return "Try restarting the AR session"
        case .invalidConfiguration:
            return "Check your configuration settings"
        case .timeout:
            return "Try moving to a well-lit area"
        case .interrupted:
            return "Return to the app to resume"
        case .sensorUnavailable:
            return "Ensure all sensors are functional"
        case .insufficientLighting:
            return "Move to a better lit environment"
        case .excessiveMotion:
            return "Hold the device more steadily"
        case .limitedTracking:
            return "Point at feature-rich surfaces"
        }
    }
}

// MARK: - Tracking Quality

/// Represents the quality of AR tracking.
public enum ARTrackingQuality: Int, Sendable, Comparable {
    /// Tracking is not available
    case notAvailable = 0
    
    /// Tracking quality is limited
    case limited = 1
    
    /// Tracking quality is normal/good
    case normal = 2
    
    /// Tracking quality is excellent
    case excellent = 3
    
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .normal:
            return "Normal"
        case .excellent:
            return "Excellent"
        }
    }
    
    public static func < (lhs: ARTrackingQuality, rhs: ARTrackingQuality) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Session Delegate

/// Protocol for receiving AR session events.
///
/// Implement this protocol to respond to session lifecycle events
/// and tracking quality changes.
public protocol ARSessionDelegate: AnyObject {
    /// Called when the session state changes
    func session(_ session: ARCraftSession, didChangeState state: ARSessionState)
    
    /// Called when tracking quality changes
    func session(_ session: ARCraftSession, didChangeTrackingQuality quality: ARTrackingQuality)
    
    /// Called when an error occurs
    func session(_ session: ARCraftSession, didEncounterError error: ARSessionError)
    
    /// Called when a new frame is available
    func session(_ session: ARCraftSession, didUpdateFrame frame: ARFrameData)
    
    /// Called when anchors are added
    func session(_ session: ARCraftSession, didAddAnchors anchors: [ARAnchorData])
    
    /// Called when anchors are updated
    func session(_ session: ARCraftSession, didUpdateAnchors anchors: [ARAnchorData])
    
    /// Called when anchors are removed
    func session(_ session: ARCraftSession, didRemoveAnchors anchors: [ARAnchorData])
}

// MARK: - Default Delegate Implementation

public extension ARSessionDelegate {
    func session(_ session: ARCraftSession, didChangeState state: ARSessionState) {}
    func session(_ session: ARCraftSession, didChangeTrackingQuality quality: ARTrackingQuality) {}
    func session(_ session: ARCraftSession, didEncounterError error: ARSessionError) {}
    func session(_ session: ARCraftSession, didUpdateFrame frame: ARFrameData) {}
    func session(_ session: ARCraftSession, didAddAnchors anchors: [ARAnchorData]) {}
    func session(_ session: ARCraftSession, didUpdateAnchors anchors: [ARAnchorData]) {}
    func session(_ session: ARCraftSession, didRemoveAnchors anchors: [ARAnchorData]) {}
}

// MARK: - Frame Data

/// Contains data from a single AR frame.
public struct ARFrameData: Sendable {
    /// Timestamp of the frame
    public let timestamp: TimeInterval
    
    /// Camera transform matrix
    public let cameraTransform: simd_float4x4
    
    /// Camera projection matrix
    public let projectionMatrix: simd_float4x4
    
    /// Ambient light intensity estimate
    public let lightEstimate: Float?
    
    /// Current tracking quality
    public let trackingQuality: ARTrackingQuality
    
    /// Creates a new frame data instance
    public init(
        timestamp: TimeInterval,
        cameraTransform: simd_float4x4,
        projectionMatrix: simd_float4x4,
        lightEstimate: Float?,
        trackingQuality: ARTrackingQuality
    ) {
        self.timestamp = timestamp
        self.cameraTransform = cameraTransform
        self.projectionMatrix = projectionMatrix
        self.lightEstimate = lightEstimate
        self.trackingQuality = trackingQuality
    }
    
    /// Camera position extracted from transform
    public var cameraPosition: SIMD3<Float> {
        SIMD3<Float>(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )
    }
    
    /// Camera forward direction
    public var cameraForward: SIMD3<Float> {
        normalize(SIMD3<Float>(
            -cameraTransform.columns.2.x,
            -cameraTransform.columns.2.y,
            -cameraTransform.columns.2.z
        ))
    }
}

// MARK: - Anchor Data

/// Generic anchor data structure for cross-platform compatibility.
public struct ARAnchorData: Identifiable, Sendable {
    /// Unique identifier for the anchor
    public let id: UUID
    
    /// Human-readable name
    public let name: String?
    
    /// Transform of the anchor in world space
    public let transform: simd_float4x4
    
    /// Type of anchor
    public let type: ARAnchorType
    
    /// Whether the anchor is currently being tracked
    public let isTracked: Bool
    
    /// Creates a new anchor data instance
    public init(
        id: UUID = UUID(),
        name: String? = nil,
        transform: simd_float4x4,
        type: ARAnchorType,
        isTracked: Bool = true
    ) {
        self.id = id
        self.name = name
        self.transform = transform
        self.type = type
        self.isTracked = isTracked
    }
    
    /// Position of the anchor
    public var position: SIMD3<Float> {
        SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }
}

// MARK: - Anchor Type

/// Types of AR anchors supported by ARCraft.
public enum ARAnchorType: String, Sendable, CaseIterable {
    case world
    case plane
    case image
    case object
    case face
    case body
    case hand
    case custom
}

// MARK: - AR Session

/// Main AR session manager for ARCraft.
///
/// `ARCraftSession` provides a unified interface for managing AR experiences
/// across iOS and visionOS platforms. It handles session lifecycle, tracking,
/// and anchor management.
///
/// ## Topics
///
/// ### Creating a Session
/// - ``init(configuration:)``
/// - ``shared``
///
/// ### Managing Session State
/// - ``start()``
/// - ``pause()``
/// - ``resume()``
/// - ``stop()``
///
/// ### Observing Changes
/// - ``state``
/// - ``trackingQuality``
/// - ``delegate``
@MainActor
public final class ARCraftSession: ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared session instance for convenience
    public static let shared = ARCraftSession()
    
    // MARK: - Published Properties
    
    /// Current state of the session
    @Published public private(set) var state: ARSessionState = .notStarted
    
    /// Current tracking quality
    @Published public private(set) var trackingQuality: ARTrackingQuality = .notAvailable
    
    /// Current frame data
    @Published public private(set) var currentFrame: ARFrameData?
    
    /// Active anchors in the session
    @Published public private(set) var anchors: [ARAnchorData] = []
    
    /// Whether AR is supported on this device
    @Published public private(set) var isSupported: Bool = false
    
    // MARK: - Properties
    
    /// Delegate for receiving session events
    public weak var delegate: ARSessionDelegate?
    
    /// Session configuration
    public var configuration: ARCraftConfiguration
    
    /// Frame update rate (frames per second)
    public var targetFrameRate: Int = 60
    
    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Session start time
    private var sessionStartTime: Date?
    
    /// Frame counter for statistics
    private var frameCount: UInt64 = 0
    
    /// Last frame timestamp
    private var lastFrameTimestamp: TimeInterval = 0
    
    // MARK: - Initialization
    
    /// Creates a new AR session with the given configuration.
    ///
    /// - Parameter configuration: Configuration options for the session
    public init(configuration: ARCraftConfiguration = .default) {
        self.configuration = configuration
        checkSupport()
    }
    
    // MARK: - Support Check
    
    private func checkSupport() {
        #if os(iOS)
        isSupported = true
        #elseif os(visionOS)
        isSupported = true
        #else
        isSupported = false
        #endif
    }
    
    // MARK: - Session Control
    
    /// Starts the AR session.
    ///
    /// Call this method to begin AR tracking. The session will transition
    /// through initializing to running state if successful.
    ///
    /// - Throws: `ARSessionError` if the session cannot be started
    public func start() async throws {
        guard isSupported else {
            throw ARSessionError.notSupported
        }
        
        guard state != .running else { return }
        
        updateState(.initializing)
        
        do {
            try await initializeSession()
            sessionStartTime = Date()
            frameCount = 0
            updateState(.running)
        } catch {
            updateState(.error)
            throw error
        }
    }
    
    /// Pauses the AR session.
    ///
    /// Temporarily suspends tracking while preserving session state.
    public func pause() {
        guard state == .running else { return }
        updateState(.paused)
    }
    
    /// Resumes a paused session.
    ///
    /// - Throws: `ARSessionError` if the session cannot be resumed
    public func resume() async throws {
        guard state == .paused else { return }
        updateState(.running)
    }
    
    /// Stops the AR session completely.
    ///
    /// Call this method when you're done with the AR experience.
    /// The session will need to be restarted with `start()` to use again.
    public func stop() {
        updateState(.stopped)
        anchors.removeAll()
        currentFrame = nil
        sessionStartTime = nil
    }
    
    // MARK: - Anchor Management
    
    /// Adds an anchor to the session.
    ///
    /// - Parameter anchor: The anchor data to add
    /// - Returns: The ID of the added anchor
    @discardableResult
    public func addAnchor(_ anchor: ARAnchorData) -> UUID {
        anchors.append(anchor)
        delegate?.session(self, didAddAnchors: [anchor])
        return anchor.id
    }
    
    /// Removes an anchor from the session.
    ///
    /// - Parameter id: The ID of the anchor to remove
    public func removeAnchor(id: UUID) {
        guard let index = anchors.firstIndex(where: { $0.id == id }) else { return }
        let anchor = anchors.remove(at: index)
        delegate?.session(self, didRemoveAnchors: [anchor])
    }
    
    /// Removes all anchors from the session.
    public func removeAllAnchors() {
        let removed = anchors
        anchors.removeAll()
        if !removed.isEmpty {
            delegate?.session(self, didRemoveAnchors: removed)
        }
    }
    
    /// Finds anchors near a given position.
    ///
    /// - Parameters:
    ///   - position: The world position to search near
    ///   - radius: Maximum distance from position
    /// - Returns: Array of nearby anchors
    public func findAnchors(near position: SIMD3<Float>, radius: Float) -> [ARAnchorData] {
        anchors.filter { anchor in
            distance(anchor.position, position) <= radius
        }
    }
    
    // MARK: - Private Methods
    
    private func initializeSession() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        if configuration.requiresWorldTracking {
            trackingQuality = .normal
        }
    }
    
    private func updateState(_ newState: ARSessionState) {
        let oldState = state
        state = newState
        
        if oldState != newState {
            delegate?.session(self, didChangeState: newState)
        }
    }
    
    private func updateTrackingQuality(_ quality: ARTrackingQuality) {
        let oldQuality = trackingQuality
        trackingQuality = quality
        
        if oldQuality != quality {
            delegate?.session(self, didChangeTrackingQuality: quality)
        }
    }
    
    // MARK: - Statistics
    
    /// Duration of the current session in seconds
    public var sessionDuration: TimeInterval {
        guard let start = sessionStartTime else { return 0 }
        return Date().timeIntervalSince(start)
    }
    
    /// Average frame rate since session started
    public var averageFrameRate: Double {
        guard sessionDuration > 0 else { return 0 }
        return Double(frameCount) / sessionDuration
    }
    
    /// Total number of frames processed
    public var totalFrames: UInt64 {
        frameCount
    }
}

// MARK: - Session Factory

/// Factory for creating pre-configured AR sessions.
public enum ARSessionFactory {
    /// Creates a session optimized for world tracking
    public static func worldTrackingSession() -> ARCraftSession {
        let config = ARCraftConfiguration()
        config.trackingMode = .world
        config.planeDetection = [.horizontal, .vertical]
        return ARCraftSession(configuration: config)
    }
    
    /// Creates a session optimized for image tracking
    public static func imageTrackingSession() -> ARCraftSession {
        let config = ARCraftConfiguration()
        config.trackingMode = .image
        return ARCraftSession(configuration: config)
    }
    
    /// Creates a session optimized for face tracking
    public static func faceTrackingSession() -> ARCraftSession {
        let config = ARCraftConfiguration()
        config.trackingMode = .face
        return ARCraftSession(configuration: config)
    }
    
    /// Creates a session with minimal resource usage
    public static func lightweightSession() -> ARCraftSession {
        let config = ARCraftConfiguration()
        config.trackingMode = .world
        config.planeDetection = []
        config.environmentTexturing = .none
        return ARCraftSession(configuration: config)
    }
}
