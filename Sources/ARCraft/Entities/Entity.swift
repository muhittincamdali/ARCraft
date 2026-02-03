//
//  Entity.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import Combine
import simd

// MARK: - Transform

/// Represents a 3D transform with position, rotation, and scale.
public struct Transform3D: Sendable, Equatable {
    /// Position in 3D space
    public var position: SIMD3<Float>
    
    /// Rotation as quaternion
    public var rotation: simd_quatf
    
    /// Scale factor
    public var scale: SIMD3<Float>
    
    /// Identity transform
    public static let identity = Transform3D(
        position: .zero,
        rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
        scale: SIMD3<Float>(1, 1, 1)
    )
    
    /// Creates a new transform
    public init(
        position: SIMD3<Float> = .zero,
        rotation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
        scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
    
    /// Creates a transform from a 4x4 matrix
    public init(matrix: simd_float4x4) {
        self.position = SIMD3<Float>(matrix.columns.3.x, matrix.columns.3.y, matrix.columns.3.z)
        
        let sx = length(SIMD3<Float>(matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z))
        let sy = length(SIMD3<Float>(matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z))
        let sz = length(SIMD3<Float>(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z))
        self.scale = SIMD3<Float>(sx, sy, sz)
        
        var rotMatrix = simd_float3x3(
            SIMD3<Float>(matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z) / sx,
            SIMD3<Float>(matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z) / sy,
            SIMD3<Float>(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z) / sz
        )
        self.rotation = simd_quatf(rotMatrix)
    }
    
    /// Converts to a 4x4 matrix
    public var matrix: simd_float4x4 {
        let rotMatrix = simd_float3x3(rotation)
        
        let col0 = SIMD4<Float>(rotMatrix.columns.0 * scale.x, 0)
        let col1 = SIMD4<Float>(rotMatrix.columns.1 * scale.y, 0)
        let col2 = SIMD4<Float>(rotMatrix.columns.2 * scale.z, 0)
        let col3 = SIMD4<Float>(position, 1)
        
        return simd_float4x4(col0, col1, col2, col3)
    }
    
    /// Euler angles in radians
    public var eulerAngles: SIMD3<Float> {
        let matrix = simd_float3x3(rotation)
        
        let sy = sqrt(matrix.columns.0.x * matrix.columns.0.x + matrix.columns.1.x * matrix.columns.1.x)
        
        var x: Float, y: Float, z: Float
        
        if sy > 1e-6 {
            x = atan2(matrix.columns.2.y, matrix.columns.2.z)
            y = atan2(-matrix.columns.2.x, sy)
            z = atan2(matrix.columns.1.x, matrix.columns.0.x)
        } else {
            x = atan2(-matrix.columns.1.z, matrix.columns.1.y)
            y = atan2(-matrix.columns.2.x, sy)
            z = 0
        }
        
        return SIMD3<Float>(x, y, z)
    }
    
    /// Forward direction
    public var forward: SIMD3<Float> {
        rotation.act(SIMD3<Float>(0, 0, -1))
    }
    
    /// Up direction
    public var up: SIMD3<Float> {
        rotation.act(SIMD3<Float>(0, 1, 0))
    }
    
    /// Right direction
    public var right: SIMD3<Float> {
        rotation.act(SIMD3<Float>(1, 0, 0))
    }
    
    /// Interpolates between two transforms
    public static func lerp(_ a: Transform3D, _ b: Transform3D, t: Float) -> Transform3D {
        Transform3D(
            position: mix(a.position, b.position, t: t),
            rotation: simd_slerp(a.rotation, b.rotation, t),
            scale: mix(a.scale, b.scale, t: t)
        )
    }
}

// MARK: - Entity State

/// State of an entity in the scene.
public enum EntityState: String, Sendable, Equatable {
    /// Entity is active and updated
    case active
    
    /// Entity is paused
    case paused
    
    /// Entity is hidden
    case hidden
    
    /// Entity is being removed
    case removing
}

// MARK: - Component Protocol

/// Protocol for entity components.
public protocol EntityComponent: AnyObject {
    /// Unique identifier for the component type
    static var componentID: String { get }
    
    /// Called when the component is attached to an entity
    func didAttach(to entity: ARCraftEntity)
    
    /// Called when the component is detached from an entity
    func willDetach(from entity: ARCraftEntity)
    
    /// Updates the component
    func update(deltaTime: TimeInterval)
}

public extension EntityComponent {
    func didAttach(to entity: ARCraftEntity) {}
    func willDetach(from entity: ARCraftEntity) {}
    func update(deltaTime: TimeInterval) {}
}

// MARK: - Entity

/// Base entity class for AR content.
///
/// `ARCraftEntity` represents an object in the AR scene with transform,
/// hierarchy, and component-based functionality.
///
/// ## Example
///
/// ```swift
/// let entity = ARCraftEntity(name: "Cube")
/// entity.transform.position = SIMD3<Float>(0, 0, -1)
///
/// // Add to scene
/// coordinator.addEntity(entity)
///
/// // Add components
/// entity.addComponent(PhysicsComponent())
/// ```
public class ARCraftEntity: Identifiable, @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Unique identifier
    public let id: UUID
    
    /// Name of the entity
    public var name: String
    
    /// Transform of the entity
    public var transform: Transform3D
    
    /// Current state
    public private(set) var state: EntityState = .active
    
    /// Whether the entity is enabled
    public var isEnabled: Bool = true
    
    /// Whether the entity is visible
    public var isVisible: Bool = true
    
    /// Parent entity
    public weak var parent: ARCraftEntity?
    
    /// Child entities
    public private(set) var children: [ARCraftEntity] = []
    
    /// Components attached to this entity
    private var components: [String: EntityComponent] = [:]
    
    /// User data
    public var userData: [String: Any] = [:]
    
    /// Tags for grouping
    public var tags: Set<String> = []
    
    /// Layer mask for rendering/physics
    public var layerMask: UInt32 = 0xFFFFFFFF
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a new entity.
    ///
    /// - Parameter name: Name of the entity
    public init(name: String = "Entity") {
        self.id = UUID()
        self.name = name
        self.transform = .identity
    }
    
    /// Creates an entity with a position.
    ///
    /// - Parameters:
    ///   - name: Name of the entity
    ///   - position: Initial position
    public convenience init(name: String, position: SIMD3<Float>) {
        self.init(name: name)
        self.transform.position = position
    }
    
    // MARK: - World Transform
    
    /// World transform accounting for parent hierarchy
    public var worldTransform: Transform3D {
        if let parent = parent {
            let parentWorld = parent.worldTransform
            let parentMatrix = parentWorld.matrix
            let localMatrix = transform.matrix
            return Transform3D(matrix: parentMatrix * localMatrix)
        }
        return transform
    }
    
    /// World position
    public var worldPosition: SIMD3<Float> {
        worldTransform.position
    }
    
    /// Sets world position
    public func setWorldPosition(_ position: SIMD3<Float>) {
        if let parent = parent {
            let parentInverse = parent.worldTransform.matrix.inverse
            let worldPoint = SIMD4<Float>(position, 1)
            let local = parentInverse * worldPoint
            transform.position = SIMD3<Float>(local.x, local.y, local.z)
        } else {
            transform.position = position
        }
    }
    
    // MARK: - Hierarchy
    
    /// Adds a child entity.
    ///
    /// - Parameter child: Entity to add as child
    public func addChild(_ child: ARCraftEntity) {
        lock.lock()
        defer { lock.unlock() }
        
        child.parent?.removeChild(child)
        child.parent = self
        children.append(child)
    }
    
    /// Removes a child entity.
    ///
    /// - Parameter child: Entity to remove
    public func removeChild(_ child: ARCraftEntity) {
        lock.lock()
        defer { lock.unlock() }
        
        children.removeAll { $0.id == child.id }
        child.parent = nil
    }
    
    /// Removes all children.
    public func removeAllChildren() {
        lock.lock()
        defer { lock.unlock() }
        
        for child in children {
            child.parent = nil
        }
        children.removeAll()
    }
    
    /// Finds a child by name.
    ///
    /// - Parameter name: Name to search for
    /// - Returns: Child entity if found
    public func findChild(named name: String) -> ARCraftEntity? {
        lock.lock()
        defer { lock.unlock() }
        
        for child in children {
            if child.name == name {
                return child
            }
            if let found = child.findChild(named: name) {
                return found
            }
        }
        return nil
    }
    
    /// Gets all descendants.
    public var allDescendants: [ARCraftEntity] {
        lock.lock()
        defer { lock.unlock() }
        
        var result = children
        for child in children {
            result.append(contentsOf: child.allDescendants)
        }
        return result
    }
    
    // MARK: - Components
    
    /// Adds a component to the entity.
    ///
    /// - Parameter component: Component to add
    public func addComponent(_ component: EntityComponent) {
        lock.lock()
        defer { lock.unlock() }
        
        let id = type(of: component).componentID
        components[id] = component
        component.didAttach(to: self)
    }
    
    /// Removes a component by type.
    ///
    /// - Parameter type: Component type to remove
    public func removeComponent<T: EntityComponent>(_ type: T.Type) {
        lock.lock()
        defer { lock.unlock() }
        
        let id = type.componentID
        if let component = components.removeValue(forKey: id) {
            component.willDetach(from: self)
        }
    }
    
    /// Gets a component by type.
    ///
    /// - Parameter type: Component type to get
    /// - Returns: Component if found
    public func component<T: EntityComponent>(_ type: T.Type) -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        return components[type.componentID] as? T
    }
    
    /// Checks if entity has a component type.
    ///
    /// - Parameter type: Component type
    /// - Returns: Whether component exists
    public func hasComponent<T: EntityComponent>(_ type: T.Type) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        return components[type.componentID] != nil
    }
    
    // MARK: - State
    
    /// Sets the entity state.
    public func setState(_ state: EntityState) {
        self.state = state
    }
    
    /// Activates the entity.
    public func activate() {
        state = .active
        isEnabled = true
    }
    
    /// Pauses the entity.
    public func pause() {
        state = .paused
    }
    
    /// Hides the entity.
    public func hide() {
        state = .hidden
        isVisible = false
    }
    
    /// Shows the entity.
    public func show() {
        state = .active
        isVisible = true
    }
    
    // MARK: - Update
    
    /// Updates the entity.
    ///
    /// - Parameter deltaTime: Time since last update
    public func update(deltaTime: TimeInterval) {
        guard state == .active && isEnabled else { return }
        
        lock.lock()
        let componentsCopy = Array(components.values)
        lock.unlock()
        
        for component in componentsCopy {
            component.update(deltaTime: deltaTime)
        }
        
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }
    
    // MARK: - Interaction
    
    /// Handles an interaction event.
    ///
    /// - Parameter interaction: The interaction to handle
    public func handleInteraction(_ interaction: ARInteraction) {
        // Override in subclasses
    }
    
    /// Ray intersection test.
    ///
    /// - Parameter ray: Screen point for ray
    /// - Returns: Intersection point if any
    public func intersects(ray: CGPoint) -> SIMD3<Float>? {
        // Override in subclasses for proper bounds checking
        return nil
    }
    
    // MARK: - Tags
    
    /// Adds a tag.
    public func addTag(_ tag: String) {
        tags.insert(tag)
    }
    
    /// Removes a tag.
    public func removeTag(_ tag: String) {
        tags.remove(tag)
    }
    
    /// Checks if entity has a tag.
    public func hasTag(_ tag: String) -> Bool {
        tags.contains(tag)
    }
    
    // MARK: - Distance
    
    /// Distance to another entity.
    public func distance(to other: ARCraftEntity) -> Float {
        simd.distance(worldPosition, other.worldPosition)
    }
    
    /// Distance to a point.
    public func distance(to point: SIMD3<Float>) -> Float {
        simd.distance(worldPosition, point)
    }
    
    // MARK: - Look At
    
    /// Rotates to look at a target.
    ///
    /// - Parameters:
    ///   - target: Target position
    ///   - up: Up vector
    public func lookAt(_ target: SIMD3<Float>, up: SIMD3<Float> = SIMD3<Float>(0, 1, 0)) {
        let direction = normalize(target - worldPosition)
        let right = normalize(cross(up, direction))
        let newUp = cross(direction, right)
        
        let rotMatrix = simd_float3x3(
            right,
            newUp,
            -direction
        )
        
        transform.rotation = simd_quatf(rotMatrix)
    }
}

// MARK: - Entity Factory

/// Factory for creating common entity types.
public enum EntityFactory {
    /// Creates an empty entity
    public static func empty(name: String = "Empty") -> ARCraftEntity {
        ARCraftEntity(name: name)
    }
    
    /// Creates an entity at a position
    public static func entity(at position: SIMD3<Float>, name: String = "Entity") -> ARCraftEntity {
        ARCraftEntity(name: name, position: position)
    }
    
    /// Creates a container entity for grouping
    public static func container(name: String = "Container") -> ARCraftEntity {
        let entity = ARCraftEntity(name: name)
        entity.addTag("container")
        return entity
    }
}
