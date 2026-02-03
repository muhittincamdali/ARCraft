//
//  ARCoordinator.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import Combine
import simd

#if canImport(RealityKit)
import RealityKit
#endif

// MARK: - Coordinator State

/// Represents the state of the AR coordinator.
public enum ARCoordinatorState: String, Sendable, Equatable {
    /// Coordinator is idle and not managing any experience
    case idle
    
    /// Coordinator is setting up the AR experience
    case setup
    
    /// Coordinator is actively managing the AR experience
    case active
    
    /// Coordinator is cleaning up resources
    case cleanup
    
    /// Coordinator encountered an error
    case error
}

// MARK: - Experience Type

/// Types of AR experiences that can be coordinated.
public enum ARExperienceType: String, Sendable, CaseIterable {
    /// Interactive world-space experience
    case worldSpace
    
    /// Image marker-based experience
    case imageMarker
    
    /// Face-attached experience
    case faceAttached
    
    /// Location-based experience
    case locationBased
    
    /// Portal or immersive experience
    case immersive
    
    /// Shared multi-user experience
    case collaborative
}

// MARK: - Coordinator Delegate

/// Protocol for receiving coordinator events.
public protocol ARCoordinatorDelegate: AnyObject {
    /// Called when the coordinator state changes
    func coordinator(_ coordinator: ARCoordinator, didChangeState state: ARCoordinatorState)
    
    /// Called when an entity is added to the scene
    func coordinator(_ coordinator: ARCoordinator, didAddEntity entity: ARCraftEntity)
    
    /// Called when an entity is removed from the scene
    func coordinator(_ coordinator: ARCoordinator, didRemoveEntity entity: ARCraftEntity)
    
    /// Called when a user interaction occurs
    func coordinator(_ coordinator: ARCoordinator, didReceiveInteraction interaction: ARInteraction)
    
    /// Called when the experience is ready
    func coordinatorDidBecomeReady(_ coordinator: ARCoordinator)
    
    /// Called when an error occurs
    func coordinator(_ coordinator: ARCoordinator, didEncounterError error: Error)
}

// MARK: - Default Delegate Implementation

public extension ARCoordinatorDelegate {
    func coordinator(_ coordinator: ARCoordinator, didChangeState state: ARCoordinatorState) {}
    func coordinator(_ coordinator: ARCoordinator, didAddEntity entity: ARCraftEntity) {}
    func coordinator(_ coordinator: ARCoordinator, didRemoveEntity entity: ARCraftEntity) {}
    func coordinator(_ coordinator: ARCoordinator, didReceiveInteraction interaction: ARInteraction) {}
    func coordinatorDidBecomeReady(_ coordinator: ARCoordinator) {}
    func coordinator(_ coordinator: ARCoordinator, didEncounterError error: Error) {}
}

// MARK: - Interaction

/// Represents a user interaction with the AR scene.
public struct ARInteraction: Sendable {
    /// Type of interaction
    public let type: InteractionType
    
    /// Location of the interaction in screen coordinates
    public let screenLocation: CGPoint
    
    /// Location in world coordinates (if available)
    public let worldLocation: SIMD3<Float>?
    
    /// Entity that was interacted with (if any)
    public let targetEntityID: UUID?
    
    /// Timestamp of the interaction
    public let timestamp: TimeInterval
    
    /// Interaction type enumeration
    public enum InteractionType: String, Sendable {
        case tap
        case doubleTap
        case longPress
        case pan
        case pinch
        case rotation
        case drag
        case hover
    }
    
    /// Creates a new interaction
    public init(
        type: InteractionType,
        screenLocation: CGPoint,
        worldLocation: SIMD3<Float>? = nil,
        targetEntityID: UUID? = nil,
        timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        self.type = type
        self.screenLocation = screenLocation
        self.worldLocation = worldLocation
        self.targetEntityID = targetEntityID
        self.timestamp = timestamp
    }
}

// MARK: - Scene Graph

/// Manages the hierarchy of entities in the AR scene.
public final class ARSceneGraph: @unchecked Sendable {
    
    /// Root entity of the scene
    private var rootEntity: ARCraftEntity?
    
    /// All entities indexed by ID
    private var entityIndex: [UUID: ARCraftEntity] = [:]
    
    /// Parent-child relationships
    private var parentMap: [UUID: UUID] = [:]
    
    /// Children of each entity
    private var childrenMap: [UUID: [UUID]] = [:]
    
    private let lock = NSLock()
    
    /// Creates a new scene graph
    public init() {
        let root = ARCraftEntity(name: "Root")
        self.rootEntity = root
        entityIndex[root.id] = root
        childrenMap[root.id] = []
    }
    
    /// Returns the root entity
    public var root: ARCraftEntity? {
        lock.lock()
        defer { lock.unlock() }
        return rootEntity
    }
    
    /// Returns all entities in the scene
    public var allEntities: [ARCraftEntity] {
        lock.lock()
        defer { lock.unlock() }
        return Array(entityIndex.values)
    }
    
    /// Number of entities in the scene
    public var entityCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return entityIndex.count
    }
    
    /// Adds an entity to the scene
    public func addEntity(_ entity: ARCraftEntity, parent: ARCraftEntity? = nil) {
        lock.lock()
        defer { lock.unlock() }
        
        let parentID = parent?.id ?? rootEntity?.id
        guard let actualParentID = parentID else { return }
        
        entityIndex[entity.id] = entity
        parentMap[entity.id] = actualParentID
        
        if childrenMap[actualParentID] == nil {
            childrenMap[actualParentID] = []
        }
        childrenMap[actualParentID]?.append(entity.id)
        childrenMap[entity.id] = []
    }
    
    /// Removes an entity from the scene
    public func removeEntity(_ entity: ARCraftEntity) {
        lock.lock()
        defer { lock.unlock() }
        
        removeEntityRecursive(entity.id)
    }
    
    private func removeEntityRecursive(_ entityID: UUID) {
        if let children = childrenMap[entityID] {
            for childID in children {
                removeEntityRecursive(childID)
            }
        }
        
        if let parentID = parentMap[entityID] {
            childrenMap[parentID]?.removeAll { $0 == entityID }
        }
        
        entityIndex.removeValue(forKey: entityID)
        parentMap.removeValue(forKey: entityID)
        childrenMap.removeValue(forKey: entityID)
    }
    
    /// Finds an entity by ID
    public func findEntity(id: UUID) -> ARCraftEntity? {
        lock.lock()
        defer { lock.unlock() }
        return entityIndex[id]
    }
    
    /// Finds entities by name
    public func findEntities(named name: String) -> [ARCraftEntity] {
        lock.lock()
        defer { lock.unlock() }
        return entityIndex.values.filter { $0.name == name }
    }
    
    /// Gets the parent of an entity
    public func parent(of entity: ARCraftEntity) -> ARCraftEntity? {
        lock.lock()
        defer { lock.unlock() }
        guard let parentID = parentMap[entity.id] else { return nil }
        return entityIndex[parentID]
    }
    
    /// Gets the children of an entity
    public func children(of entity: ARCraftEntity) -> [ARCraftEntity] {
        lock.lock()
        defer { lock.unlock() }
        guard let childIDs = childrenMap[entity.id] else { return [] }
        return childIDs.compactMap { entityIndex[$0] }
    }
    
    /// Clears all entities except root
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        
        guard let rootID = rootEntity?.id else { return }
        
        entityIndex = [rootID: rootEntity!]
        parentMap = [:]
        childrenMap = [rootID: []]
    }
}

// MARK: - AR Coordinator

/// Main coordinator for managing AR experiences.
///
/// `ARCoordinator` provides high-level management of AR experiences,
/// including entity management, interaction handling, and scene lifecycle.
///
/// ## Example
///
/// ```swift
/// let coordinator = ARCoordinator()
/// coordinator.delegate = self
///
/// await coordinator.setup(experienceType: .worldSpace)
/// coordinator.addEntity(myEntity, at: position)
/// ```
@MainActor
public final class ARCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current state of the coordinator
    @Published public private(set) var state: ARCoordinatorState = .idle
    
    /// Type of experience being coordinated
    @Published public private(set) var experienceType: ARExperienceType?
    
    /// Whether the experience is ready for interaction
    @Published public private(set) var isReady: Bool = false
    
    /// Current frame rate
    @Published public private(set) var frameRate: Double = 0
    
    // MARK: - Properties
    
    /// Delegate for receiving coordinator events
    public weak var delegate: ARCoordinatorDelegate?
    
    /// The AR session being coordinated
    public let session: ARCraftSession
    
    /// Scene graph for entity management
    public let sceneGraph: ARSceneGraph
    
    /// Gesture handler for interactions
    public var gestureHandler: GestureHandler?
    
    /// Animation controller
    public var animationController: AnimationController?
    
    /// Physics world
    public var physicsWorld: PhysicsWorld?
    
    /// Anchor manager
    public var anchorManager: AnchorManager?
    
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount: Int = 0
    private var frameRateUpdateInterval: TimeInterval = 1.0
    private var lastFrameRateUpdate: TimeInterval = 0
    
    // MARK: - Initialization
    
    /// Creates a new coordinator with the given session.
    public init(session: ARCraftSession = .shared) {
        self.session = session
        self.sceneGraph = ARSceneGraph()
        setupBindings()
    }
    
    private func setupBindings() {
        session.$state
            .sink { [weak self] sessionState in
                self?.handleSessionStateChange(sessionState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup
    
    /// Sets up the coordinator for a specific experience type.
    ///
    /// - Parameter experienceType: The type of AR experience to set up
    public func setup(experienceType: ARExperienceType) async throws {
        guard state == .idle else { return }
        
        updateState(.setup)
        self.experienceType = experienceType
        
        configureForExperience(experienceType)
        
        do {
            try await session.start()
            
            anchorManager = AnchorManager()
            animationController = AnimationController()
            physicsWorld = PhysicsWorld()
            gestureHandler = GestureHandler()
            
            updateState(.active)
            isReady = true
            delegate?.coordinatorDidBecomeReady(self)
            
            startUpdateLoop()
        } catch {
            updateState(.error)
            delegate?.coordinator(self, didEncounterError: error)
            throw error
        }
    }
    
    private func configureForExperience(_ type: ARExperienceType) {
        switch type {
        case .worldSpace:
            session.configuration.trackingMode = .world
            session.configuration.planeDetection = .all
            
        case .imageMarker:
            session.configuration.trackingMode = .image
            
        case .faceAttached:
            session.configuration.trackingMode = .face
            
        case .locationBased:
            session.configuration.trackingMode = .geo
            
        case .immersive:
            session.configuration.trackingMode = .world
            session.configuration.sceneReconstruction = [.mesh]
            
        case .collaborative:
            session.configuration.trackingMode = .world
            session.configuration.collaborationEnabled = true
        }
    }
    
    // MARK: - Entity Management
    
    /// Adds an entity to the scene.
    ///
    /// - Parameters:
    ///   - entity: The entity to add
    ///   - position: Optional world position
    ///   - parent: Optional parent entity
    public func addEntity(_ entity: ARCraftEntity, at position: SIMD3<Float>? = nil, parent: ARCraftEntity? = nil) {
        if let position = position {
            entity.transform.position = position
        }
        
        sceneGraph.addEntity(entity, parent: parent)
        delegate?.coordinator(self, didAddEntity: entity)
    }
    
    /// Removes an entity from the scene.
    ///
    /// - Parameter entity: The entity to remove
    public func removeEntity(_ entity: ARCraftEntity) {
        sceneGraph.removeEntity(entity)
        delegate?.coordinator(self, didRemoveEntity: entity)
    }
    
    /// Finds an entity by ID.
    ///
    /// - Parameter id: The entity ID to find
    /// - Returns: The entity if found
    public func findEntity(id: UUID) -> ARCraftEntity? {
        sceneGraph.findEntity(id: id)
    }
    
    /// Finds entities by name.
    ///
    /// - Parameter name: The name to search for
    /// - Returns: Array of matching entities
    public func findEntities(named name: String) -> [ARCraftEntity] {
        sceneGraph.findEntities(named: name)
    }
    
    // MARK: - Interaction Handling
    
    /// Handles an interaction event.
    ///
    /// - Parameter interaction: The interaction to handle
    public func handleInteraction(_ interaction: ARInteraction) {
        delegate?.coordinator(self, didReceiveInteraction: interaction)
        
        if let targetID = interaction.targetEntityID,
           let entity = findEntity(id: targetID) {
            entity.handleInteraction(interaction)
        }
    }
    
    // MARK: - Ray Casting
    
    /// Performs a ray cast from screen coordinates.
    ///
    /// - Parameters:
    ///   - screenPoint: The screen point to cast from
    ///   - types: Types of surfaces to intersect
    /// - Returns: Array of ray cast results
    public func raycast(from screenPoint: CGPoint, targeting types: RaycastTargetType) -> [RaycastResult] {
        var results: [RaycastResult] = []
        
        for entity in sceneGraph.allEntities {
            if let intersection = entity.intersects(ray: screenPoint) {
                let result = RaycastResult(
                    position: intersection,
                    normal: SIMD3<Float>(0, 1, 0),
                    entity: entity,
                    distance: distance(session.currentFrame?.cameraPosition ?? .zero, intersection)
                )
                results.append(result)
            }
        }
        
        return results.sorted { $0.distance < $1.distance }
    }
    
    // MARK: - Update Loop
    
    private func startUpdateLoop() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.update()
            }
        }
    }
    
    private func stopUpdateLoop() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func update() {
        let currentTime = ProcessInfo.processInfo.systemUptime
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        frameCount += 1
        
        if currentTime - lastFrameRateUpdate >= frameRateUpdateInterval {
            frameRate = Double(frameCount) / (currentTime - lastFrameRateUpdate)
            frameCount = 0
            lastFrameRateUpdate = currentTime
        }
        
        animationController?.update(deltaTime: deltaTime)
        physicsWorld?.simulate(deltaTime: deltaTime)
        
        for entity in sceneGraph.allEntities {
            entity.update(deltaTime: deltaTime)
        }
    }
    
    // MARK: - State Management
    
    private func updateState(_ newState: ARCoordinatorState) {
        let oldState = state
        state = newState
        
        if oldState != newState {
            delegate?.coordinator(self, didChangeState: newState)
        }
    }
    
    private func handleSessionStateChange(_ sessionState: ARSessionState) {
        switch sessionState {
        case .stopped, .error:
            isReady = false
            
        case .running:
            if state == .active {
                isReady = true
            }
            
        default:
            break
        }
    }
    
    // MARK: - Cleanup
    
    /// Stops the coordinator and cleans up resources.
    public func stop() {
        updateState(.cleanup)
        
        stopUpdateLoop()
        sceneGraph.clear()
        session.stop()
        
        anchorManager = nil
        animationController = nil
        physicsWorld = nil
        gestureHandler = nil
        
        isReady = false
        experienceType = nil
        
        updateState(.idle)
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - Raycast Types

/// Types of surfaces that can be targeted by raycasts.
public struct RaycastTargetType: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Estimated planes
    public static let estimatedPlane = RaycastTargetType(rawValue: 1 << 0)
    
    /// Existing plane anchors
    public static let existingPlaneGeometry = RaycastTargetType(rawValue: 1 << 1)
    
    /// Scene mesh
    public static let sceneMesh = RaycastTargetType(rawValue: 1 << 2)
    
    /// Entities in the scene
    public static let entities = RaycastTargetType(rawValue: 1 << 3)
    
    /// All available surfaces
    public static let all: RaycastTargetType = [.estimatedPlane, .existingPlaneGeometry, .sceneMesh, .entities]
}

/// Result of a raycast operation.
public struct RaycastResult: Sendable {
    /// World position of the intersection
    public let position: SIMD3<Float>
    
    /// Surface normal at intersection
    public let normal: SIMD3<Float>
    
    /// Entity that was hit (if any)
    public let entity: ARCraftEntity?
    
    /// Distance from ray origin
    public let distance: Float
    
    /// Creates a new raycast result
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
