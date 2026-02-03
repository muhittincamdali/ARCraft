//
//  PhysicsWorld.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Physics Body Type

/// Type of physics body.
public enum PhysicsBodyType: String, Sendable, CaseIterable {
    /// Static body - doesn't move
    case `static`
    
    /// Dynamic body - fully simulated
    case dynamic
    
    /// Kinematic body - controlled by animation
    case kinematic
    
    /// Description
    public var description: String {
        rawValue.capitalized
    }
}

// MARK: - Physics Material

/// Physics material properties.
public struct PhysicsMaterial: Sendable, Equatable {
    /// Friction coefficient (0-1)
    public var friction: Float
    
    /// Restitution (bounciness, 0-1)
    public var restitution: Float
    
    /// Density
    public var density: Float
    
    /// Creates physics material
    public init(
        friction: Float = 0.5,
        restitution: Float = 0.3,
        density: Float = 1.0
    ) {
        self.friction = max(0, min(1, friction))
        self.restitution = max(0, min(1, restitution))
        self.density = max(0.001, density)
    }
    
    /// Default material
    public static let `default` = PhysicsMaterial()
    
    /// Rubber-like material
    public static let rubber = PhysicsMaterial(friction: 0.9, restitution: 0.8, density: 1.1)
    
    /// Metal material
    public static let metal = PhysicsMaterial(friction: 0.3, restitution: 0.2, density: 7.8)
    
    /// Wood material
    public static let wood = PhysicsMaterial(friction: 0.5, restitution: 0.4, density: 0.6)
    
    /// Ice material
    public static let ice = PhysicsMaterial(friction: 0.05, restitution: 0.1, density: 0.9)
    
    /// Concrete material
    public static let concrete = PhysicsMaterial(friction: 0.7, restitution: 0.1, density: 2.4)
}

// MARK: - Collision Filter

/// Filter for collision detection.
public struct CollisionFilter: Sendable, Equatable {
    /// Category bits for this body
    public var categoryBits: UInt32
    
    /// Collision mask - which categories to collide with
    public var collisionMask: UInt32
    
    /// Contact mask - which categories to report contacts for
    public var contactMask: UInt32
    
    /// Creates a collision filter
    public init(
        categoryBits: UInt32 = 0xFFFFFFFF,
        collisionMask: UInt32 = 0xFFFFFFFF,
        contactMask: UInt32 = 0
    ) {
        self.categoryBits = categoryBits
        self.collisionMask = collisionMask
        self.contactMask = contactMask
    }
    
    /// Default filter - collides with everything
    public static let `default` = CollisionFilter()
    
    /// Checks if this filter should collide with another
    public func shouldCollide(with other: CollisionFilter) -> Bool {
        (categoryBits & other.collisionMask) != 0 &&
        (collisionMask & other.categoryBits) != 0
    }
}

// MARK: - Physics Body

/// A physics body attached to an entity.
public final class PhysicsBody: Identifiable, @unchecked Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Entity this body belongs to
    public weak var entity: ARCraftEntity?
    
    /// Body type
    public var type: PhysicsBodyType
    
    /// Physics material
    public var material: PhysicsMaterial
    
    /// Collision filter
    public var filter: CollisionFilter
    
    /// Mass (computed from density and shape for dynamic bodies)
    public var mass: Float
    
    /// Linear velocity
    public var linearVelocity: SIMD3<Float>
    
    /// Angular velocity
    public var angularVelocity: SIMD3<Float>
    
    /// Linear damping
    public var linearDamping: Float
    
    /// Angular damping
    public var angularDamping: Float
    
    /// Gravity scale
    public var gravityScale: Float
    
    /// Whether the body is affected by gravity
    public var affectedByGravity: Bool
    
    /// Whether continuous collision detection is enabled
    public var isContinuous: Bool
    
    /// Whether the body is currently awake
    public var isAwake: Bool
    
    /// Collision shapes
    public var shapes: [PhysicsShape]
    
    /// Forces to apply
    private var pendingForces: [(SIMD3<Float>, SIMD3<Float>?)] = []
    
    /// Impulses to apply
    private var pendingImpulses: [(SIMD3<Float>, SIMD3<Float>?)] = []
    
    private let lock = NSLock()
    
    /// Creates a physics body
    public init(
        entity: ARCraftEntity? = nil,
        type: PhysicsBodyType = .dynamic,
        material: PhysicsMaterial = .default
    ) {
        self.id = UUID()
        self.entity = entity
        self.type = type
        self.material = material
        self.filter = .default
        self.mass = 1.0
        self.linearVelocity = .zero
        self.angularVelocity = .zero
        self.linearDamping = 0.1
        self.angularDamping = 0.1
        self.gravityScale = 1.0
        self.affectedByGravity = type == .dynamic
        self.isContinuous = false
        self.isAwake = true
        self.shapes = []
    }
    
    /// Adds a collision shape
    public func addShape(_ shape: PhysicsShape) {
        shapes.append(shape)
        recalculateMass()
    }
    
    /// Removes all shapes
    public func removeAllShapes() {
        shapes.removeAll()
        mass = 0
    }
    
    /// Recalculates mass from shapes
    private func recalculateMass() {
        guard type == .dynamic else {
            mass = 0
            return
        }
        
        mass = shapes.reduce(0) { total, shape in
            total + shape.volume * material.density
        }
    }
    
    /// Applies a force
    public func applyForce(_ force: SIMD3<Float>, at position: SIMD3<Float>? = nil) {
        guard type == .dynamic else { return }
        lock.lock()
        pendingForces.append((force, position))
        lock.unlock()
        isAwake = true
    }
    
    /// Applies an impulse
    public func applyImpulse(_ impulse: SIMD3<Float>, at position: SIMD3<Float>? = nil) {
        guard type == .dynamic else { return }
        lock.lock()
        pendingImpulses.append((impulse, position))
        lock.unlock()
        isAwake = true
    }
    
    /// Applies torque
    public func applyTorque(_ torque: SIMD3<Float>) {
        guard type == .dynamic else { return }
        angularVelocity += torque / max(mass, 0.001)
        isAwake = true
    }
    
    /// Sets velocity directly
    public func setVelocity(_ velocity: SIMD3<Float>) {
        linearVelocity = velocity
        isAwake = length(velocity) > 0.001
    }
    
    /// Processes pending forces and impulses
    func processPendingForces(deltaTime: Float) {
        lock.lock()
        let forces = pendingForces
        let impulses = pendingImpulses
        pendingForces.removeAll()
        pendingImpulses.removeAll()
        lock.unlock()
        
        guard mass > 0 else { return }
        
        // Apply forces (F = ma, so a = F/m)
        for (force, _) in forces {
            linearVelocity += force / mass * deltaTime
        }
        
        // Apply impulses (instant velocity change)
        for (impulse, _) in impulses {
            linearVelocity += impulse / mass
        }
    }
    
    /// Kinetic energy
    public var kineticEnergy: Float {
        0.5 * mass * length_squared(linearVelocity)
    }
    
    /// Momentum
    public var momentum: SIMD3<Float> {
        linearVelocity * mass
    }
}

// MARK: - Physics Shape

/// Shape for collision detection.
public struct PhysicsShape: Sendable, Equatable {
    /// Shape type
    public var type: ShapeType
    
    /// Local offset from body center
    public var offset: SIMD3<Float>
    
    /// Local rotation
    public var rotation: simd_quatf
    
    /// Shape type enum
    public enum ShapeType: Sendable, Equatable {
        case box(SIMD3<Float>)
        case sphere(Float)
        case capsule(Float, Float)
        case cylinder(Float, Float)
        case convexHull
        case mesh
    }
    
    /// Creates a physics shape
    public init(
        type: ShapeType,
        offset: SIMD3<Float> = .zero,
        rotation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    ) {
        self.type = type
        self.offset = offset
        self.rotation = rotation
    }
    
    /// Creates a box shape
    public static func box(_ size: SIMD3<Float>) -> PhysicsShape {
        PhysicsShape(type: .box(size))
    }
    
    /// Creates a sphere shape
    public static func sphere(_ radius: Float) -> PhysicsShape {
        PhysicsShape(type: .sphere(radius))
    }
    
    /// Creates a capsule shape
    public static func capsule(radius: Float, height: Float) -> PhysicsShape {
        PhysicsShape(type: .capsule(radius, height))
    }
    
    /// Volume of the shape
    public var volume: Float {
        switch type {
        case .box(let size):
            return size.x * size.y * size.z
        case .sphere(let radius):
            return (4.0 / 3.0) * .pi * radius * radius * radius
        case .capsule(let radius, let height):
            let sphereVol = (4.0 / 3.0) * .pi * radius * radius * radius
            let cylVol = .pi * radius * radius * height
            return sphereVol + cylVol
        case .cylinder(let radius, let height):
            return .pi * radius * radius * height
        case .convexHull, .mesh:
            return 1.0 // Placeholder
        }
    }
}

// MARK: - Collision Event

/// Event from collision detection.
public struct CollisionEvent: Sendable {
    /// First body involved
    public let bodyA: UUID
    
    /// Second body involved
    public let bodyB: UUID
    
    /// Contact point in world space
    public let contactPoint: SIMD3<Float>
    
    /// Contact normal (from A to B)
    public let normal: SIMD3<Float>
    
    /// Penetration depth
    public let penetration: Float
    
    /// Relative velocity at contact
    public let relativeVelocity: SIMD3<Float>
    
    /// Event type
    public let type: EventType
    
    /// Event type enum
    public enum EventType: String, Sendable {
        case began
        case persisted
        case ended
    }
}

// MARK: - Physics World

/// Physics simulation world.
///
/// `PhysicsWorld` manages physics simulation for AR entities,
/// handling collision detection, response, and body dynamics.
///
/// ## Example
///
/// ```swift
/// let world = PhysicsWorld()
/// world.gravity = SIMD3<Float>(0, -9.81, 0)
///
/// let body = PhysicsBody(entity: cube, type: .dynamic)
/// body.addShape(.box(SIMD3<Float>(0.1, 0.1, 0.1)))
/// world.addBody(body)
///
/// // In update loop
/// world.simulate(deltaTime: 1/60)
/// ```
public final class PhysicsWorld: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Gravity acceleration
    public var gravity: SIMD3<Float>
    
    /// All bodies in the world
    private var bodies: [UUID: PhysicsBody] = [:]
    
    /// Simulation speed multiplier
    public var timeScale: Float = 1.0
    
    /// Maximum simulation substeps per frame
    public var maxSubsteps: Int = 4
    
    /// Fixed timestep for substeps
    public var fixedTimestep: Float = 1.0 / 60.0
    
    /// Whether simulation is paused
    public var isPaused: Bool = false
    
    /// Accumulated time for fixed timestep
    private var accumulatedTime: Float = 0
    
    /// Collision event callback
    public var onCollision: ((CollisionEvent) -> Void)?
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a physics world
    public init(gravity: SIMD3<Float> = SIMD3<Float>(0, -9.81, 0)) {
        self.gravity = gravity
    }
    
    // MARK: - Body Management
    
    /// Adds a body to the world
    public func addBody(_ body: PhysicsBody) {
        lock.lock()
        defer { lock.unlock() }
        bodies[body.id] = body
    }
    
    /// Removes a body from the world
    public func removeBody(_ body: PhysicsBody) {
        lock.lock()
        defer { lock.unlock() }
        bodies.removeValue(forKey: body.id)
    }
    
    /// Removes body by ID
    public func removeBody(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        bodies.removeValue(forKey: id)
    }
    
    /// Gets a body by ID
    public func body(id: UUID) -> PhysicsBody? {
        lock.lock()
        defer { lock.unlock() }
        return bodies[id]
    }
    
    /// All bodies in the world
    public var allBodies: [PhysicsBody] {
        lock.lock()
        defer { lock.unlock() }
        return Array(bodies.values)
    }
    
    /// Number of bodies
    public var bodyCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return bodies.count
    }
    
    // MARK: - Simulation
    
    /// Simulates one frame
    public func simulate(deltaTime: TimeInterval) {
        guard !isPaused else { return }
        
        let scaledDelta = Float(deltaTime) * timeScale
        accumulatedTime += scaledDelta
        
        var steps = 0
        while accumulatedTime >= fixedTimestep && steps < maxSubsteps {
            step(fixedTimestep)
            accumulatedTime -= fixedTimestep
            steps += 1
        }
        
        // Handle remaining time
        if accumulatedTime > fixedTimestep {
            accumulatedTime = 0
        }
    }
    
    private func step(_ dt: Float) {
        lock.lock()
        let bodyList = Array(bodies.values)
        lock.unlock()
        
        // Process forces
        for body in bodyList {
            body.processPendingForces(deltaTime: dt)
        }
        
        // Apply gravity
        for body in bodyList where body.type == .dynamic && body.affectedByGravity {
            body.linearVelocity += gravity * body.gravityScale * dt
        }
        
        // Apply damping
        for body in bodyList where body.type == .dynamic {
            body.linearVelocity *= (1 - body.linearDamping * dt)
            body.angularVelocity *= (1 - body.angularDamping * dt)
        }
        
        // Integrate velocities
        for body in bodyList where body.type == .dynamic && body.isAwake {
            guard let entity = body.entity else { continue }
            
            entity.transform.position += body.linearVelocity * dt
            
            if length(body.angularVelocity) > 0.001 {
                let angle = length(body.angularVelocity) * dt
                let axis = normalize(body.angularVelocity)
                let deltaRot = simd_quatf(angle: angle, axis: axis)
                entity.transform.rotation = deltaRot * entity.transform.rotation
            }
            
            // Sleep check
            if length(body.linearVelocity) < 0.001 && length(body.angularVelocity) < 0.001 {
                body.linearVelocity = .zero
                body.angularVelocity = .zero
                body.isAwake = false
            }
        }
        
        // Collision detection (simplified)
        detectCollisions(bodyList)
    }
    
    private func detectCollisions(_ bodies: [PhysicsBody]) {
        for i in 0..<bodies.count {
            for j in (i+1)..<bodies.count {
                let bodyA = bodies[i]
                let bodyB = bodies[j]
                
                guard bodyA.filter.shouldCollide(with: bodyB.filter) else { continue }
                guard bodyA.isAwake || bodyB.isAwake else { continue }
                
                if let collision = checkCollision(bodyA, bodyB) {
                    resolveCollision(collision, bodyA, bodyB)
                    onCollision?(collision)
                }
            }
        }
    }
    
    private func checkCollision(_ a: PhysicsBody, _ b: PhysicsBody) -> CollisionEvent? {
        guard let entityA = a.entity, let entityB = b.entity else { return nil }
        
        // Simplified sphere-based collision check
        let posA = entityA.worldPosition
        let posB = entityB.worldPosition
        let distance = simd.distance(posA, posB)
        
        let radiusA = a.shapes.first.map { shape -> Float in
            switch shape.type {
            case .sphere(let r): return r
            case .box(let s): return length(s) * 0.5
            default: return 0.1
            }
        } ?? 0.1
        
        let radiusB = b.shapes.first.map { shape -> Float in
            switch shape.type {
            case .sphere(let r): return r
            case .box(let s): return length(s) * 0.5
            default: return 0.1
            }
        } ?? 0.1
        
        let combinedRadius = radiusA + radiusB
        
        if distance < combinedRadius {
            let normal = normalize(posB - posA)
            let contactPoint = posA + normal * radiusA
            let penetration = combinedRadius - distance
            
            return CollisionEvent(
                bodyA: a.id,
                bodyB: b.id,
                contactPoint: contactPoint,
                normal: normal,
                penetration: penetration,
                relativeVelocity: b.linearVelocity - a.linearVelocity,
                type: .began
            )
        }
        
        return nil
    }
    
    private func resolveCollision(_ collision: CollisionEvent, _ a: PhysicsBody, _ b: PhysicsBody) {
        guard let entityA = a.entity, let entityB = b.entity else { return }
        
        // Separate bodies
        let separation = collision.normal * collision.penetration * 0.5
        
        if a.type == .dynamic {
            entityA.transform.position -= separation
        }
        if b.type == .dynamic {
            entityB.transform.position += separation
        }
        
        // Apply impulse response
        let restitution = min(a.material.restitution, b.material.restitution)
        let relVel = dot(collision.relativeVelocity, collision.normal)
        
        if relVel < 0 {
            let massA = a.type == .dynamic ? a.mass : Float.infinity
            let massB = b.type == .dynamic ? b.mass : Float.infinity
            let totalMass = massA + massB
            
            let j = -(1 + restitution) * relVel / (1/massA + 1/massB)
            let impulse = collision.normal * j
            
            if a.type == .dynamic {
                a.linearVelocity -= impulse / massA
            }
            if b.type == .dynamic {
                b.linearVelocity += impulse / massB
            }
        }
    }
    
    // MARK: - Raycasting
    
    /// Performs a raycast
    public func raycast(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        maxDistance: Float = 1000
    ) -> RaycastHit? {
        lock.lock()
        let bodyList = Array(bodies.values)
        lock.unlock()
        
        var closestHit: RaycastHit?
        var closestDist = maxDistance
        
        for body in bodyList {
            guard let entity = body.entity else { continue }
            
            for shape in body.shapes {
                if let dist = rayIntersectsShape(
                    origin: origin,
                    direction: direction,
                    shape: shape,
                    position: entity.worldPosition
                ), dist < closestDist {
                    closestDist = dist
                    closestHit = RaycastHit(
                        body: body,
                        point: origin + direction * dist,
                        normal: normalize(origin - entity.worldPosition),
                        distance: dist
                    )
                }
            }
        }
        
        return closestHit
    }
    
    private func rayIntersectsShape(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        shape: PhysicsShape,
        position: SIMD3<Float>
    ) -> Float? {
        switch shape.type {
        case .sphere(let radius):
            let oc = origin - position
            let b = dot(oc, direction)
            let c = dot(oc, oc) - radius * radius
            let discriminant = b * b - c
            if discriminant > 0 {
                return -b - sqrt(discriminant)
            }
        default:
            break
        }
        return nil
    }
    
    // MARK: - Utility
    
    /// Removes all bodies
    public func clear() {
        lock.lock()
        bodies.removeAll()
        lock.unlock()
    }
    
    /// Wakes all bodies
    public func wakeAll() {
        lock.lock()
        for body in bodies.values {
            body.isAwake = true
        }
        lock.unlock()
    }
}

// MARK: - Raycast Hit

/// Result of a raycast.
public struct RaycastHit: Sendable {
    /// Body that was hit
    public let body: PhysicsBody
    
    /// Hit point in world space
    public let point: SIMD3<Float>
    
    /// Surface normal at hit point
    public let normal: SIMD3<Float>
    
    /// Distance from ray origin
    public let distance: Float
}
