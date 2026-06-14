#if os(iOS) || os(visionOS)
import Foundation
import RealityKit

/// A high-performance physics engine wrapper for RealityKit.
@available(iOS 15.0, visionOS 1.0, *)
public actor VisionPhysicsEngine {
    public init() {}
    
    /// Applies realistic mass and friction to a virtual entity.
    public func applyMaterial(to entity: Entity, mass: Float, friction: Float) {
        let physics = PhysicsBodyComponent(massProperties: .init(mass: mass), material: .generate(friction: friction, restitution: 0.5), mode: .dynamic)
        entity.components.set(physics)
        print("🧱 [ARCraft] Applied physical properties: mass=\(mass), friction=\\(friction)")
    }
}
#endif
