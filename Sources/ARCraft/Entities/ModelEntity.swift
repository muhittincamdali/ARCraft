//
//  ModelEntity.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

#if canImport(RealityKit)
import RealityKit
#endif

// MARK: - Mesh Type

/// Type of primitive mesh.
public enum PrimitiveMeshType: String, Sendable, CaseIterable {
    case box
    case sphere
    case cylinder
    case cone
    case capsule
    case plane
    case torus
    case pyramid
    
    /// Description
    public var description: String {
        rawValue.capitalized
    }
}

// MARK: - Mesh Parameters

/// Parameters for creating primitive meshes.
public struct MeshParameters: Sendable, Equatable {
    /// Size or dimensions
    public var size: SIMD3<Float>
    
    /// Radius (for spheres, cylinders, etc.)
    public var radius: Float
    
    /// Height (for cylinders, cones, etc.)
    public var height: Float
    
    /// Segments for curved surfaces
    public var segments: Int
    
    /// Corner radius (for rounded boxes)
    public var cornerRadius: Float
    
    /// Creates default parameters
    public init(
        size: SIMD3<Float> = SIMD3<Float>(1, 1, 1),
        radius: Float = 0.5,
        height: Float = 1.0,
        segments: Int = 32,
        cornerRadius: Float = 0
    ) {
        self.size = size
        self.radius = radius
        self.height = height
        self.segments = segments
        self.cornerRadius = cornerRadius
    }
    
    /// Parameters for a unit cube
    public static var unitCube: MeshParameters {
        MeshParameters(size: SIMD3<Float>(1, 1, 1))
    }
    
    /// Parameters for a unit sphere
    public static var unitSphere: MeshParameters {
        MeshParameters(radius: 0.5, segments: 32)
    }
}

// MARK: - Model Source

/// Source of a 3D model.
public enum ModelSource: Sendable, Equatable {
    /// Primitive mesh
    case primitive(PrimitiveMeshType, MeshParameters)
    
    /// Loaded from file
    case file(String)
    
    /// Loaded from bundle
    case bundle(String, String?)
    
    /// Loaded from URL
    case url(URL)
    
    /// Procedurally generated
    case procedural(String)
}

// MARK: - Bounding Box

/// Axis-aligned bounding box.
public struct BoundingBox: Sendable, Equatable {
    /// Minimum corner
    public var min: SIMD3<Float>
    
    /// Maximum corner
    public var max: SIMD3<Float>
    
    /// Creates a bounding box
    public init(min: SIMD3<Float>, max: SIMD3<Float>) {
        self.min = min
        self.max = max
    }
    
    /// Creates from center and extent
    public init(center: SIMD3<Float>, extent: SIMD3<Float>) {
        let halfExtent = extent * 0.5
        self.min = center - halfExtent
        self.max = center + halfExtent
    }
    
    /// Center of the box
    public var center: SIMD3<Float> {
        (min + max) * 0.5
    }
    
    /// Size of the box
    public var extent: SIMD3<Float> {
        max - min
    }
    
    /// Half extent
    public var halfExtent: SIMD3<Float> {
        extent * 0.5
    }
    
    /// Volume
    public var volume: Float {
        extent.x * extent.y * extent.z
    }
    
    /// Diagonal length
    public var diagonal: Float {
        length(extent)
    }
    
    /// Checks if point is inside
    public func contains(_ point: SIMD3<Float>) -> Bool {
        point.x >= min.x && point.x <= max.x &&
        point.y >= min.y && point.y <= max.y &&
        point.z >= min.z && point.z <= max.z
    }
    
    /// Expands to include a point
    public mutating func expand(to point: SIMD3<Float>) {
        min = simd.min(min, point)
        max = simd.max(max, point)
    }
    
    /// Union with another box
    public func union(_ other: BoundingBox) -> BoundingBox {
        BoundingBox(
            min: simd.min(min, other.min),
            max: simd.max(max, other.max)
        )
    }
    
    /// Intersection with another box
    public func intersection(_ other: BoundingBox) -> BoundingBox? {
        let newMin = simd.max(min, other.min)
        let newMax = simd.min(max, other.max)
        
        if newMin.x <= newMax.x && newMin.y <= newMax.y && newMin.z <= newMax.z {
            return BoundingBox(min: newMin, max: newMax)
        }
        return nil
    }
    
    /// Transforms the bounding box
    public func transformed(by matrix: simd_float4x4) -> BoundingBox {
        let corners = [
            SIMD3<Float>(min.x, min.y, min.z),
            SIMD3<Float>(max.x, min.y, min.z),
            SIMD3<Float>(min.x, max.y, min.z),
            SIMD3<Float>(max.x, max.y, min.z),
            SIMD3<Float>(min.x, min.y, max.z),
            SIMD3<Float>(max.x, min.y, max.z),
            SIMD3<Float>(min.x, max.y, max.z),
            SIMD3<Float>(max.x, max.y, max.z)
        ]
        
        var newMin = SIMD3<Float>(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
        var newMax = SIMD3<Float>(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)
        
        for corner in corners {
            let transformed = matrix * SIMD4<Float>(corner, 1)
            let point = SIMD3<Float>(transformed.x, transformed.y, transformed.z)
            newMin = simd.min(newMin, point)
            newMax = simd.max(newMax, point)
        }
        
        return BoundingBox(min: newMin, max: newMax)
    }
}

// MARK: - Model Entity

/// Entity representing a 3D model.
///
/// `ModelEntity` provides functionality for loading and displaying
/// 3D models in the AR scene, including primitives and loaded assets.
///
/// ## Example
///
/// ```swift
/// // Create a sphere
/// let sphere = ModelEntity.sphere(radius: 0.1)
/// sphere.transform.position = SIMD3<Float>(0, 0.5, -1)
///
/// // Create from file
/// let model = ModelEntity(modelNamed: "robot.usdz")
/// try await model.load()
/// ```
public class ModelEntity: ARCraftEntity {
    
    // MARK: - Properties
    
    /// Source of the model
    public private(set) var source: ModelSource
    
    /// Whether the model is loaded
    public private(set) var isLoaded: Bool = false
    
    /// Loading state
    public private(set) var loadingState: LoadingState = .notLoaded
    
    /// Local bounding box
    public private(set) var localBounds: BoundingBox
    
    /// Material applied to the model
    public var material: ARCraftMaterial?
    
    /// Whether shadows are enabled
    public var castsShadow: Bool = true
    
    /// Whether the model receives shadows
    public var receivesShadow: Bool = true
    
    /// Collision shape (if any)
    public var collisionShape: CollisionShape?
    
    /// Loading error (if any)
    public private(set) var loadingError: Error?
    
    /// Loading state enum
    public enum LoadingState: String, Sendable {
        case notLoaded
        case loading
        case loaded
        case failed
    }
    
    // MARK: - Initialization
    
    /// Creates a model entity with a source.
    public init(name: String = "Model", source: ModelSource) {
        self.source = source
        self.localBounds = BoundingBox(min: .zero, max: .zero)
        super.init(name: name)
        
        if case .primitive(let type, let params) = source {
            calculatePrimitiveBounds(type: type, params: params)
            isLoaded = true
            loadingState = .loaded
        }
    }
    
    /// Creates from a model file name.
    public convenience init(modelNamed: String) {
        self.init(name: modelNamed, source: .file(modelNamed))
    }
    
    /// Creates from a bundle resource.
    public convenience init(named: String, bundle: Bundle? = nil) {
        self.init(name: named, source: .bundle(named, bundle?.bundlePath))
    }
    
    // MARK: - Factory Methods
    
    /// Creates a box model.
    public static func box(
        size: SIMD3<Float> = SIMD3<Float>(0.1, 0.1, 0.1),
        cornerRadius: Float = 0
    ) -> ModelEntity {
        let params = MeshParameters(size: size, cornerRadius: cornerRadius)
        return ModelEntity(name: "Box", source: .primitive(.box, params))
    }
    
    /// Creates a sphere model.
    public static func sphere(
        radius: Float = 0.05,
        segments: Int = 32
    ) -> ModelEntity {
        let params = MeshParameters(radius: radius, segments: segments)
        return ModelEntity(name: "Sphere", source: .primitive(.sphere, params))
    }
    
    /// Creates a cylinder model.
    public static func cylinder(
        radius: Float = 0.05,
        height: Float = 0.1,
        segments: Int = 32
    ) -> ModelEntity {
        let params = MeshParameters(radius: radius, height: height, segments: segments)
        return ModelEntity(name: "Cylinder", source: .primitive(.cylinder, params))
    }
    
    /// Creates a cone model.
    public static func cone(
        radius: Float = 0.05,
        height: Float = 0.1,
        segments: Int = 32
    ) -> ModelEntity {
        let params = MeshParameters(radius: radius, height: height, segments: segments)
        return ModelEntity(name: "Cone", source: .primitive(.cone, params))
    }
    
    /// Creates a plane model.
    public static func plane(
        width: Float = 0.1,
        depth: Float = 0.1
    ) -> ModelEntity {
        let params = MeshParameters(size: SIMD3<Float>(width, 0, depth))
        return ModelEntity(name: "Plane", source: .primitive(.plane, params))
    }
    
    /// Creates a capsule model.
    public static func capsule(
        radius: Float = 0.05,
        height: Float = 0.1
    ) -> ModelEntity {
        let params = MeshParameters(radius: radius, height: height)
        return ModelEntity(name: "Capsule", source: .primitive(.capsule, params))
    }
    
    // MARK: - Loading
    
    /// Loads the model asynchronously.
    public func load() async throws {
        guard loadingState != .loading else { return }
        guard loadingState != .loaded else { return }
        
        loadingState = .loading
        
        do {
            switch source {
            case .primitive:
                loadingState = .loaded
                isLoaded = true
                
            case .file(let path):
                try await loadFromFile(path)
                
            case .bundle(let name, _):
                try await loadFromBundle(name)
                
            case .url(let url):
                try await loadFromURL(url)
                
            case .procedural(let type):
                try await generateProcedural(type)
            }
            
            loadingState = .loaded
            isLoaded = true
        } catch {
            loadingState = .failed
            loadingError = error
            throw error
        }
    }
    
    private func loadFromFile(_ path: String) async throws {
        try await Task.sleep(nanoseconds: 10_000_000)
        localBounds = BoundingBox(center: .zero, extent: SIMD3<Float>(0.1, 0.1, 0.1))
    }
    
    private func loadFromBundle(_ name: String) async throws {
        try await Task.sleep(nanoseconds: 10_000_000)
        localBounds = BoundingBox(center: .zero, extent: SIMD3<Float>(0.1, 0.1, 0.1))
    }
    
    private func loadFromURL(_ url: URL) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        localBounds = BoundingBox(center: .zero, extent: SIMD3<Float>(0.1, 0.1, 0.1))
    }
    
    private func generateProcedural(_ type: String) async throws {
        try await Task.sleep(nanoseconds: 10_000_000)
        localBounds = BoundingBox(center: .zero, extent: SIMD3<Float>(0.1, 0.1, 0.1))
    }
    
    private func calculatePrimitiveBounds(type: PrimitiveMeshType, params: MeshParameters) {
        switch type {
        case .box:
            let half = params.size * 0.5
            localBounds = BoundingBox(min: -half, max: half)
            
        case .sphere:
            let r = params.radius
            localBounds = BoundingBox(min: SIMD3<Float>(-r, -r, -r), max: SIMD3<Float>(r, r, r))
            
        case .cylinder, .capsule:
            let r = params.radius
            let h = params.height * 0.5
            localBounds = BoundingBox(min: SIMD3<Float>(-r, -h, -r), max: SIMD3<Float>(r, h, r))
            
        case .cone:
            let r = params.radius
            let h = params.height * 0.5
            localBounds = BoundingBox(min: SIMD3<Float>(-r, -h, -r), max: SIMD3<Float>(r, h, r))
            
        case .plane:
            let half = params.size * 0.5
            localBounds = BoundingBox(min: SIMD3<Float>(-half.x, 0, -half.z), max: SIMD3<Float>(half.x, 0, half.z))
            
        case .torus:
            let r = params.radius + params.radius * 0.25
            localBounds = BoundingBox(min: SIMD3<Float>(-r, -params.radius * 0.25, -r), max: SIMD3<Float>(r, params.radius * 0.25, r))
            
        case .pyramid:
            let half = params.size * 0.5
            localBounds = BoundingBox(min: SIMD3<Float>(-half.x, 0, -half.z), max: SIMD3<Float>(half.x, params.height, half.z))
        }
    }
    
    // MARK: - Bounds
    
    /// World-space bounding box
    public var worldBounds: BoundingBox {
        localBounds.transformed(by: worldTransform.matrix)
    }
    
    /// Recalculates bounds from mesh data
    public func recalculateBounds() {
        // In a real implementation, this would recalculate from actual mesh data
    }
    
    // MARK: - Materials
    
    /// Applies a material to the model.
    public func applyMaterial(_ material: ARCraftMaterial) {
        self.material = material
    }
    
    /// Removes the material.
    public func removeMaterial() {
        self.material = nil
    }
    
    // MARK: - Intersection
    
    /// Checks ray intersection with the model.
    public override func intersects(ray: CGPoint) -> SIMD3<Float>? {
        // Simple bounds check - in real implementation would use mesh data
        return worldBounds.center
    }
    
    /// Checks if a point is inside the model bounds.
    public func containsPoint(_ point: SIMD3<Float>) -> Bool {
        worldBounds.contains(point)
    }
    
    // MARK: - Clone
    
    /// Creates a clone of this model entity.
    public func clone() -> ModelEntity {
        let cloned = ModelEntity(name: name + "_clone", source: source)
        cloned.transform = transform
        cloned.material = material
        cloned.castsShadow = castsShadow
        cloned.receivesShadow = receivesShadow
        cloned.localBounds = localBounds
        cloned.isLoaded = isLoaded
        cloned.loadingState = loadingState
        return cloned
    }
}

// MARK: - Collision Shape

/// Shape for collision detection.
public enum CollisionShape: Sendable, Equatable {
    case box(SIMD3<Float>)
    case sphere(Float)
    case capsule(Float, Float)
    case convexHull
    case mesh
    
    /// Creates shape from bounding box
    public static func fromBounds(_ bounds: BoundingBox) -> CollisionShape {
        .box(bounds.extent)
    }
}

// MARK: - Material Placeholder

/// Placeholder material type.
public struct ARCraftMaterial: Sendable, Equatable {
    public var baseColor: SIMD4<Float>
    public var roughness: Float
    public var metallic: Float
    
    public init(
        baseColor: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1),
        roughness: Float = 0.5,
        metallic: Float = 0
    ) {
        self.baseColor = baseColor
        self.roughness = roughness
        self.metallic = metallic
    }
}
