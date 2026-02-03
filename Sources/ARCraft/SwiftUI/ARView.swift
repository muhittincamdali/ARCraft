//
//  ARView.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI
import Combine
import simd

#if canImport(RealityKit)
import RealityKit
#endif

// MARK: - AR View Configuration

/// Configuration for the AR view.
public struct ARViewConfiguration: Sendable {
    /// Whether to show statistics overlay
    public var showStatistics: Bool
    
    /// Whether to enable debug visualization
    public var debugVisualization: DebugVisualization
    
    /// Background color (when not using camera feed)
    public var backgroundColor: Color4
    
    /// Whether camera feed is shown
    public var showCameraFeed: Bool
    
    /// Whether to enable people occlusion
    public var peopleOcclusion: Bool
    
    /// Whether to enable object occlusion
    public var objectOcclusion: Bool
    
    /// Content scale factor
    public var contentScaleFactor: Float
    
    /// Debug visualization options
    public struct DebugVisualization: OptionSet, Sendable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let none = DebugVisualization([])
        public static let showWorldOrigin = DebugVisualization(rawValue: 1 << 0)
        public static let showFeaturePoints = DebugVisualization(rawValue: 1 << 1)
        public static let showAnchors = DebugVisualization(rawValue: 1 << 2)
        public static let showPhysics = DebugVisualization(rawValue: 1 << 3)
        public static let showStatistics = DebugVisualization(rawValue: 1 << 4)
        public static let showBoundingBoxes = DebugVisualization(rawValue: 1 << 5)
        
        public static let all: DebugVisualization = [
            .showWorldOrigin, .showFeaturePoints, .showAnchors,
            .showPhysics, .showStatistics, .showBoundingBoxes
        ]
    }
    
    /// Creates default configuration
    public init() {
        self.showStatistics = false
        self.debugVisualization = .none
        self.backgroundColor = .black
        self.showCameraFeed = true
        self.peopleOcclusion = false
        self.objectOcclusion = false
        self.contentScaleFactor = 1.0
    }
    
    /// Debug configuration
    public static var debug: ARViewConfiguration {
        var config = ARViewConfiguration()
        config.showStatistics = true
        config.debugVisualization = .all
        return config
    }
}

// MARK: - AR View State

/// State of the AR view.
@MainActor
public final class ARViewState: ObservableObject {
    /// Current session state
    @Published public var sessionState: ARSessionState = .notStarted
    
    /// Current tracking quality
    @Published public var trackingQuality: ARTrackingQuality = .notAvailable
    
    /// Current frame rate
    @Published public var frameRate: Double = 0
    
    /// Number of anchors
    @Published public var anchorCount: Int = 0
    
    /// Number of entities
    @Published public var entityCount: Int = 0
    
    /// Last error
    @Published public var lastError: ARSessionError?
    
    /// Whether the view is ready
    @Published public var isReady: Bool = false
    
    /// Creates view state
    public init() {}
}

// MARK: - AR View Delegate

/// Protocol for receiving AR view events.
@MainActor
public protocol ARViewDelegate: AnyObject {
    /// Called when the view is ready
    func arViewDidBecomeReady(_ view: ARCraftView)
    
    /// Called when session state changes
    func arView(_ view: ARCraftView, didChangeSessionState state: ARSessionState)
    
    /// Called when an entity is tapped
    func arView(_ view: ARCraftView, didTapEntity entityID: UUID, at location: CGPoint)
    
    /// Called when the background is tapped
    func arView(_ view: ARCraftView, didTapBackground at: CGPoint, worldPosition: SIMD3<Float>?)
    
    /// Called when a plane is detected
    func arView(_ view: ARCraftView, didDetectPlane plane: PlaneAnchor)
    
    /// Called when an error occurs
    func arView(_ view: ARCraftView, didEncounterError error: ARSessionError)
}

// MARK: - Default Delegate Implementation

@MainActor
public extension ARViewDelegate {
    func arViewDidBecomeReady(_ view: ARCraftView) {}
    func arView(_ view: ARCraftView, didChangeSessionState state: ARSessionState) {}
    func arView(_ view: ARCraftView, didTapEntity entityID: UUID, at location: CGPoint) {}
    func arView(_ view: ARCraftView, didTapBackground at: CGPoint, worldPosition: SIMD3<Float>?) {}
    func arView(_ view: ARCraftView, didDetectPlane plane: PlaneAnchor) {}
    func arView(_ view: ARCraftView, didEncounterError error: ARSessionError) {}
}

// MARK: - AR View

/// Main AR view for displaying AR content.
///
/// `ARCraftView` provides the primary interface for AR experiences,
/// handling rendering, gestures, and session management.
///
/// ## Example
///
/// ```swift
/// struct ContentView: View {
///     @StateObject private var viewState = ARViewState()
///     
///     var body: some View {
///         ARCraftViewRepresentable(state: viewState)
///             .onAppear {
///                 // Setup AR experience
///             }
///     }
/// }
/// ```
@MainActor
public final class ARCraftView: ObservableObject {
    
    // MARK: - Properties
    
    /// View configuration
    public var configuration: ARViewConfiguration
    
    /// View state
    @Published public var state: ARViewState
    
    /// Delegate for events
    public weak var delegate: ARViewDelegate?
    
    /// AR session
    public let session: ARCraftSession
    
    /// AR coordinator
    public let coordinator: ARCoordinator
    
    /// Gesture handler
    public let gestureHandler: GestureHandler
    
    /// Scene graph
    public var sceneGraph: ARSceneGraph {
        coordinator.sceneGraph
    }
    
    /// Frame size
    @Published public var frameSize: CGSize = .zero
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates an AR view
    public init(
        configuration: ARViewConfiguration = ARViewConfiguration(),
        session: ARCraftSession = .shared
    ) {
        self.configuration = configuration
        self.state = ARViewState()
        self.session = session
        self.coordinator = ARCoordinator(session: session)
        self.gestureHandler = GestureHandler()
        
        setupBindings()
    }
    
    private func setupBindings() {
        session.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionState in
                self?.state.sessionState = sessionState
                if let self = self {
                    self.delegate?.arView(self, didChangeSessionState: sessionState)
                }
            }
            .store(in: &cancellables)
        
        session.$trackingQuality
            .receive(on: DispatchQueue.main)
            .assign(to: &state.$trackingQuality)
        
        coordinator.$frameRate
            .receive(on: DispatchQueue.main)
            .assign(to: &state.$frameRate)
        
        coordinator.$isReady
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in
                self?.state.isReady = isReady
                if isReady, let self = self {
                    self.delegate?.arViewDidBecomeReady(self)
                }
            }
            .store(in: &cancellables)
        
        gestureHandler.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleGestureEvent(event)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Session Control
    
    /// Starts the AR session
    public func start() async throws {
        try await coordinator.setup(experienceType: .worldSpace)
    }
    
    /// Pauses the AR session
    public func pause() {
        session.pause()
    }
    
    /// Resumes the AR session
    public func resume() async throws {
        try await session.resume()
    }
    
    /// Stops the AR session
    public func stop() {
        coordinator.stop()
    }
    
    // MARK: - Entity Management
    
    /// Adds an entity to the scene
    public func addEntity(_ entity: ARCraftEntity) {
        coordinator.addEntity(entity)
        state.entityCount = sceneGraph.entityCount
    }
    
    /// Adds an entity at a specific position
    public func addEntity(_ entity: ARCraftEntity, at position: SIMD3<Float>) {
        coordinator.addEntity(entity, at: position)
        state.entityCount = sceneGraph.entityCount
    }
    
    /// Removes an entity from the scene
    public func removeEntity(_ entity: ARCraftEntity) {
        coordinator.removeEntity(entity)
        state.entityCount = sceneGraph.entityCount
    }
    
    /// Finds an entity by ID
    public func entity(id: UUID) -> ARCraftEntity? {
        coordinator.findEntity(id: id)
    }
    
    /// Finds entities by name
    public func entities(named name: String) -> [ARCraftEntity] {
        coordinator.findEntities(named: name)
    }
    
    // MARK: - Hit Testing
    
    /// Performs a hit test at a screen point
    public func hitTest(at point: CGPoint) -> [HitTestResult] {
        let raycasts = coordinator.raycast(from: point, targeting: .all)
        return raycasts.map { raycast in
            HitTestResult(
                position: raycast.position,
                normal: raycast.normal,
                entity: raycast.entity,
                distance: raycast.distance
            )
        }
    }
    
    /// Performs a hit test for planes only
    public func hitTestPlanes(at point: CGPoint) -> [HitTestResult] {
        let raycasts = coordinator.raycast(from: point, targeting: [.estimatedPlane, .existingPlaneGeometry])
        return raycasts.map { raycast in
            HitTestResult(
                position: raycast.position,
                normal: raycast.normal,
                entity: nil,
                distance: raycast.distance
            )
        }
    }
    
    // MARK: - Gesture Handling
    
    private func handleGestureEvent(_ event: GestureEvent) {
        switch event.type {
        case .tap:
            handleTap(at: event.location)
        default:
            break
        }
    }
    
    private func handleTap(at location: CGPoint) {
        let results = hitTest(at: location)
        
        if let firstEntity = results.first?.entity {
            delegate?.arView(self, didTapEntity: firstEntity.id, at: location)
        } else {
            let worldPosition = results.first?.position
            delegate?.arView(self, didTapBackground: location, worldPosition: worldPosition)
        }
    }
    
    // MARK: - Snapshot
    
    /// Captures a snapshot of the current view
    public func snapshot() async -> Data? {
        // Placeholder - actual implementation would capture frame buffer
        return nil
    }
}

// MARK: - Hit Test Result

/// Result of a hit test.
public struct HitTestResult: Sendable {
    /// World position of the hit
    public let position: SIMD3<Float>
    
    /// Surface normal at hit point
    public let normal: SIMD3<Float>
    
    /// Entity that was hit (if any)
    public let entity: ARCraftEntity?
    
    /// Distance from camera
    public let distance: Float
    
    /// Creates a hit test result
    public init(
        position: SIMD3<Float>,
        normal: SIMD3<Float>,
        entity: ARCraftEntity?,
        distance: Float
    ) {
        self.position = position
        self.normal = normal
        self.entity = entity
        self.distance = distance
    }
}

// MARK: - AR View Modifier

/// Modifier for AR views.
public struct ARViewModifier: ViewModifier {
    let showStatistics: Bool
    let onReady: (() -> Void)?
    
    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                if showStatistics {
                    StatisticsOverlay()
                }
            }
    }
}

/// Statistics overlay view
struct StatisticsOverlay: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("FPS: 60")
            Text("Entities: 0")
            Text("Draw Calls: 0")
        }
        .font(.caption.monospaced())
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .padding()
    }
}

// MARK: - View Extension

public extension View {
    /// Adds AR view modifiers
    func arViewOptions(
        showStatistics: Bool = false,
        onReady: (() -> Void)? = nil
    ) -> some View {
        modifier(ARViewModifier(showStatistics: showStatistics, onReady: onReady))
    }
}
