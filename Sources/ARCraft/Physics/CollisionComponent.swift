//
//  CollisionComponent.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Collision Mode

/// Mode for collision behavior.
public enum CollisionMode: String, Sendable, CaseIterable {
    /// Collide and respond physically
    case collide
    
    /// Trigger only - detect but don't respond
    case trigger
    
    /// No collision
    case none
    
    /// Description
    public var description: String {
        rawValue.capitalized
    }
}

// MARK: - Collision Group

/// Predefined collision groups.
public struct CollisionGroup: OptionSet, Sendable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// Default group
    public static let `default` = CollisionGroup(rawValue: 1 << 0)
    
    /// Player entities
    public static let player = CollisionGroup(rawValue: 1 << 1)
    
    /// Environment/static geometry
    public static let environment = CollisionGroup(rawValue: 1 << 2)
    
    /// Interactive objects
    public static let interactive = CollisionGroup(rawValue: 1 << 3)
    
    /// Projectiles
    public static let projectile = CollisionGroup(rawValue: 1 << 4)
    
    /// Triggers/sensors
    public static let trigger = CollisionGroup(rawValue: 1 << 5)
    
    /// UI elements
    public static let ui = CollisionGroup(rawValue: 1 << 6)
    
    /// Custom groups
    public static let custom1 = CollisionGroup(rawValue: 1 << 16)
    public static let custom2 = CollisionGroup(rawValue: 1 << 17)
    public static let custom3 = CollisionGroup(rawValue: 1 << 18)
    
    /// All groups
    public static let all = CollisionGroup(rawValue: 0xFFFFFFFF)
}

// MARK: - Contact Info

/// Information about a collision contact.
public struct ContactInfo: Sendable {
    /// Other entity involved
    public let otherEntityID: UUID
    
    /// Contact point in world space
    public let point: SIMD3<Float>
    
    /// Contact normal
    public let normal: SIMD3<Float>
    
    /// Penetration depth
    public let penetration: Float
    
    /// Impulse magnitude
    public let impulse: Float
    
    /// Relative velocity at contact
    public let relativeVelocity: SIMD3<Float>
    
    /// Creates contact info
    public init(
        otherEntityID: UUID,
        point: SIMD3<Float>,
        normal: SIMD3<Float>,
        penetration: Float,
        impulse: Float,
        relativeVelocity: SIMD3<Float>
    ) {
        self.otherEntityID = otherEntityID
        self.point = point
        self.normal = normal
        self.penetration = penetration
        self.impulse = impulse
        self.relativeVelocity = relativeVelocity
    }
}

// MARK: - Collision Handler

/// Protocol for handling collision events.
public protocol CollisionHandler: AnyObject {
    /// Called when collision begins
    func onCollisionBegan(_ contact: ContactInfo)
    
    /// Called while collision persists
    func onCollisionStay(_ contact: ContactInfo)
    
    /// Called when collision ends
    func onCollisionEnded(with entityID: UUID)
    
    /// Called when entering a trigger
    func onTriggerEnter(_ entityID: UUID)
    
    /// Called while inside a trigger
    func onTriggerStay(_ entityID: UUID)
    
    /// Called when exiting a trigger
    func onTriggerExit(_ entityID: UUID)
}

public extension CollisionHandler {
    func onCollisionBegan(_ contact: ContactInfo) {}
    func onCollisionStay(_ contact: ContactInfo) {}
    func onCollisionEnded(with entityID: UUID) {}
    func onTriggerEnter(_ entityID: UUID) {}
    func onTriggerStay(_ entityID: UUID) {}
    func onTriggerExit(_ entityID: UUID) {}
}

// MARK: - Collision Component

/// Component for collision detection on entities.
///
/// `CollisionComponent` adds collision detection capabilities
/// to entities, supporting physical collision response and
/// trigger-based interaction.
///
/// ## Example
///
/// ```swift
/// let collision = CollisionComponent()
/// collision.shapes = [.box(SIMD3<Float>(0.1, 0.1, 0.1))]
/// collision.group = .interactive
/// collision.mask = [.player, .projectile]
/// collision.mode = .collide
///
/// entity.addComponent(collision)
/// ```
public final class CollisionComponent: EntityComponent, @unchecked Sendable {
    
    public static var componentID: String { "collision" }
    
    // MARK: - Properties
    
    /// Collision shapes
    public var shapes: [PhysicsShape]
    
    /// Collision mode
    public var mode: CollisionMode
    
    /// Collision group this entity belongs to
    public var group: CollisionGroup
    
    /// Groups this entity can collide with
    public var mask: CollisionGroup
    
    /// Handler for collision events
    public weak var handler: CollisionHandler?
    
    /// Whether collision is enabled
    public var isEnabled: Bool
    
    /// Entity this component is attached to
    public weak var entity: ARCraftEntity?
    
    /// Currently colliding entities
    private var activeCollisions: Set<UUID> = []
    
    /// Currently overlapping triggers
    private var activeTriggers: Set<UUID> = []
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a collision component
    public init(
        shapes: [PhysicsShape] = [],
        mode: CollisionMode = .collide,
        group: CollisionGroup = .default,
        mask: CollisionGroup = .all
    ) {
        self.shapes = shapes
        self.mode = mode
        self.group = group
        self.mask = mask
        self.isEnabled = true
    }
    
    // MARK: - Entity Component
    
    public func didAttach(to entity: ARCraftEntity) {
        self.entity = entity
    }
    
    public func willDetach(from entity: ARCraftEntity) {
        self.entity = nil
        clearContacts()
    }
    
    public func update(deltaTime: TimeInterval) {
        // Collision detection is typically handled by physics world
    }
    
    // MARK: - Shape Management
    
    /// Adds a collision shape
    public func addShape(_ shape: PhysicsShape) {
        shapes.append(shape)
    }
    
    /// Removes all shapes
    public func removeAllShapes() {
        shapes.removeAll()
    }
    
    /// Creates shapes from entity bounds
    public func generateFromBounds() {
        guard let entity = entity as? ModelEntity else { return }
        
        let bounds = entity.localBounds
        shapes = [.box(bounds.extent)]
    }
    
    // MARK: - Collision Testing
    
    /// Tests if this component should collide with another
    public func shouldCollide(with other: CollisionComponent) -> Bool {
        guard isEnabled && other.isEnabled else { return false }
        guard mode != .none && other.mode != .none else { return false }
        
        return group.rawValue & other.mask.rawValue != 0 &&
               mask.rawValue & other.group.rawValue != 0
    }
    
    /// Gets the world-space bounding box
    public var worldBounds: BoundingBox? {
        guard let entity = entity else { return nil }
        
        var minPoint = SIMD3<Float>(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
        var maxPoint = SIMD3<Float>(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)
        
        let worldPos = entity.worldPosition
        
        for shape in shapes {
            let shapePos = worldPos + shape.offset
            
            switch shape.type {
            case .box(let size):
                let half = size * 0.5
                minPoint = simd.min(minPoint, shapePos - half)
                maxPoint = simd.max(maxPoint, shapePos + half)
                
            case .sphere(let radius):
                minPoint = simd.min(minPoint, shapePos - SIMD3<Float>(radius, radius, radius))
                maxPoint = simd.max(maxPoint, shapePos + SIMD3<Float>(radius, radius, radius))
                
            case .capsule(let radius, let height):
                let halfHeight = height * 0.5
                minPoint = simd.min(minPoint, shapePos - SIMD3<Float>(radius, halfHeight + radius, radius))
                maxPoint = simd.max(maxPoint, shapePos + SIMD3<Float>(radius, halfHeight + radius, radius))
                
            default:
                break
            }
        }
        
        guard minPoint.x < maxPoint.x else { return nil }
        return BoundingBox(min: minPoint, max: maxPoint)
    }
    
    // MARK: - Contact Management
    
    /// Reports a collision began
    public func reportCollisionBegan(_ contact: ContactInfo) {
        lock.lock()
        let isNew = activeCollisions.insert(contact.otherEntityID).inserted
        lock.unlock()
        
        if isNew {
            if mode == .trigger {
                handler?.onTriggerEnter(contact.otherEntityID)
            } else {
                handler?.onCollisionBegan(contact)
            }
        }
    }
    
    /// Reports ongoing collision
    public func reportCollisionStay(_ contact: ContactInfo) {
        lock.lock()
        let exists = activeCollisions.contains(contact.otherEntityID)
        lock.unlock()
        
        if exists {
            if mode == .trigger {
                handler?.onTriggerStay(contact.otherEntityID)
            } else {
                handler?.onCollisionStay(contact)
            }
        }
    }
    
    /// Reports collision ended
    public func reportCollisionEnded(with entityID: UUID) {
        lock.lock()
        let existed = activeCollisions.remove(entityID) != nil
        lock.unlock()
        
        if existed {
            if mode == .trigger {
                handler?.onTriggerExit(entityID)
            } else {
                handler?.onCollisionEnded(with: entityID)
            }
        }
    }
    
    /// Clears all active contacts
    public func clearContacts() {
        lock.lock()
        let collisions = activeCollisions
        activeCollisions.removeAll()
        activeTriggers.removeAll()
        lock.unlock()
        
        for entityID in collisions {
            if mode == .trigger {
                handler?.onTriggerExit(entityID)
            } else {
                handler?.onCollisionEnded(with: entityID)
            }
        }
    }
    
    /// Gets IDs of currently colliding entities
    public var collidingEntities: Set<UUID> {
        lock.lock()
        defer { lock.unlock() }
        return activeCollisions
    }
    
    /// Checks if colliding with specific entity
    public func isCollidingWith(_ entityID: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return activeCollisions.contains(entityID)
    }
}

// MARK: - Collision System

/// System for managing collision detection across entities.
public final class CollisionSystem: @unchecked Sendable {
    
    /// All collision components
    private var components: [UUID: CollisionComponent] = [:]
    
    private let lock = NSLock()
    
    /// Creates a collision system
    public init() {}
    
    /// Registers a collision component
    public func register(_ component: CollisionComponent, for entityID: UUID) {
        lock.lock()
        components[entityID] = component
        lock.unlock()
    }
    
    /// Unregisters a collision component
    public func unregister(for entityID: UUID) {
        lock.lock()
        components.removeValue(forKey: entityID)
        lock.unlock()
    }
    
    /// Updates collision detection
    public func update() {
        lock.lock()
        let componentList = Array(components)
        lock.unlock()
        
        // Broad phase - check bounds overlap
        for i in 0..<componentList.count {
            for j in (i+1)..<componentList.count {
                let (idA, compA) = componentList[i]
                let (idB, compB) = componentList[j]
                
                guard compA.shouldCollide(with: compB) else { continue }
                
                if let boundsA = compA.worldBounds,
                   let boundsB = compB.worldBounds,
                   boundsA.intersection(boundsB) != nil {
                    // Narrow phase collision detected
                    let contact = ContactInfo(
                        otherEntityID: idB,
                        point: (boundsA.center + boundsB.center) * 0.5,
                        normal: normalize(boundsB.center - boundsA.center),
                        penetration: 0,
                        impulse: 0,
                        relativeVelocity: .zero
                    )
                    
                    compA.reportCollisionBegan(contact)
                    
                    let reverseContact = ContactInfo(
                        otherEntityID: idA,
                        point: contact.point,
                        normal: -contact.normal,
                        penetration: contact.penetration,
                        impulse: contact.impulse,
                        relativeVelocity: -contact.relativeVelocity
                    )
                    compB.reportCollisionBegan(reverseContact)
                }
            }
        }
    }
    
    /// Clears all components
    public func clear() {
        lock.lock()
        components.removeAll()
        lock.unlock()
    }
}
