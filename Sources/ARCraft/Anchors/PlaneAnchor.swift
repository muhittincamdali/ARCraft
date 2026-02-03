//
//  PlaneAnchor.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Plane Alignment

/// Alignment of a detected plane.
public enum PlaneAlignment: String, Sendable, CaseIterable {
    /// Horizontal plane facing up (floor, table)
    case horizontal
    
    /// Vertical plane (wall)
    case vertical
    
    /// Plane at an angle
    case angled
    
    /// Unknown alignment
    case unknown
    
    /// Description
    public var description: String {
        switch self {
        case .horizontal: return "Horizontal"
        case .vertical: return "Vertical"
        case .angled: return "Angled"
        case .unknown: return "Unknown"
        }
    }
    
    /// Expected normal direction
    public var expectedNormal: SIMD3<Float> {
        switch self {
        case .horizontal: return SIMD3<Float>(0, 1, 0)
        case .vertical: return SIMD3<Float>(0, 0, 1)
        case .angled, .unknown: return SIMD3<Float>(0, 1, 0)
        }
    }
}

// MARK: - Plane Classification

/// Classification of what a plane represents.
public enum PlaneClassification: String, Sendable, CaseIterable {
    /// Floor surface
    case floor
    
    /// Ceiling surface
    case ceiling
    
    /// Wall surface
    case wall
    
    /// Table or desk surface
    case table
    
    /// Seat or chair surface
    case seat
    
    /// Window surface
    case window
    
    /// Door surface
    case door
    
    /// Unclassified surface
    case none
    
    /// Description
    public var description: String {
        switch self {
        case .floor: return "Floor"
        case .ceiling: return "Ceiling"
        case .wall: return "Wall"
        case .table: return "Table"
        case .seat: return "Seat"
        case .window: return "Window"
        case .door: return "Door"
        case .none: return "Unknown"
        }
    }
    
    /// Typical alignment for this classification
    public var typicalAlignment: PlaneAlignment {
        switch self {
        case .floor, .ceiling, .table, .seat:
            return .horizontal
        case .wall, .window, .door:
            return .vertical
        case .none:
            return .unknown
        }
    }
}

// MARK: - Plane Anchor

/// Represents an anchor for a detected planar surface.
///
/// `PlaneAnchor` provides geometry and classification information
/// for detected planes, allowing placement of virtual content on
/// real-world surfaces.
///
/// ## Example
///
/// ```swift
/// let plane = PlaneAnchor(
///     center: position,
///     extent: SIMD3<Float>(1, 0, 1),
///     alignment: .horizontal
/// )
///
/// // Check if point is on plane
/// if plane.contains(point: tapLocation) {
///     // Place content
/// }
/// ```
public final class PlaneAnchor: Identifiable, @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Unique identifier
    public let id: UUID
    
    /// Name of the plane
    public var name: String?
    
    /// World transform of the plane
    public private(set) var transform: simd_float4x4
    
    /// Center position in world coordinates
    public var center: SIMD3<Float> {
        SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }
    
    /// Extent of the plane (width, height, depth)
    public private(set) var extent: SIMD3<Float>
    
    /// Alignment of the plane
    public private(set) var alignment: PlaneAlignment
    
    /// Classification of the plane
    public private(set) var classification: PlaneClassification
    
    /// Whether the plane geometry has been updated
    public private(set) var geometryUpdated: Bool = false
    
    /// Boundary vertices (if available)
    public private(set) var boundaryVertices: [SIMD3<Float>] = []
    
    /// Creation timestamp
    public let createdAt: Date
    
    /// Last update timestamp
    public private(set) var updatedAt: Date
    
    /// User data
    public var userData: [String: Any] = [:]
    
    private let lock = NSLock()
    
    /// Alias for compatibility
    public enum Alignment: String, Sendable {
        case horizontal
        case vertical
        case any
    }
    
    // MARK: - Initialization
    
    /// Creates a new plane anchor.
    ///
    /// - Parameters:
    ///   - center: Center position in world space
    ///   - extent: Size of the plane
    ///   - alignment: Plane alignment
    ///   - classification: Plane classification
    public init(
        center: SIMD3<Float>,
        extent: SIMD3<Float>,
        alignment: PlaneAlignment = .horizontal,
        classification: PlaneClassification = .none
    ) {
        self.id = UUID()
        self.transform = simd_float4x4(translation: center)
        self.extent = extent
        self.alignment = alignment
        self.classification = classification
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Creates from a full transform.
    public init(
        transform: simd_float4x4,
        extent: SIMD3<Float>,
        alignment: PlaneAlignment = .horizontal,
        classification: PlaneClassification = .none
    ) {
        self.id = UUID()
        self.transform = transform
        self.extent = extent
        self.alignment = alignment
        self.classification = classification
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Geometry
    
    /// Normal vector of the plane
    public var normal: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        
        switch alignment {
        case .horizontal:
            return SIMD3<Float>(
                transform.columns.1.x,
                transform.columns.1.y,
                transform.columns.1.z
            )
        case .vertical, .angled, .unknown:
            return SIMD3<Float>(
                -transform.columns.2.x,
                -transform.columns.2.y,
                -transform.columns.2.z
            )
        }
    }
    
    /// Width of the plane
    public var width: Float {
        extent.x
    }
    
    /// Height/depth of the plane
    public var height: Float {
        extent.z
    }
    
    /// Area of the plane in square meters
    public var area: Float {
        extent.x * extent.z
    }
    
    /// Half extent for bounds calculations
    public var halfExtent: SIMD3<Float> {
        extent * 0.5
    }
    
    /// Bounding box corners
    public var corners: [SIMD3<Float>] {
        lock.lock()
        defer { lock.unlock() }
        
        let hw = extent.x * 0.5
        let hh = extent.z * 0.5
        
        let right = SIMD3<Float>(transform.columns.0.x, transform.columns.0.y, transform.columns.0.z)
        let forward = SIMD3<Float>(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)
        
        return [
            center - right * hw - forward * hh,
            center + right * hw - forward * hh,
            center + right * hw + forward * hh,
            center - right * hw + forward * hh
        ]
    }
    
    // MARK: - Updates
    
    /// Updates the plane geometry.
    ///
    /// - Parameters:
    ///   - transform: New transform
    ///   - extent: New extent
    public func update(transform: simd_float4x4, extent: SIMD3<Float>) {
        lock.lock()
        defer { lock.unlock() }
        
        self.transform = transform
        self.extent = extent
        self.geometryUpdated = true
        self.updatedAt = Date()
    }
    
    /// Updates the classification.
    ///
    /// - Parameter classification: New classification
    public func update(classification: PlaneClassification) {
        lock.lock()
        defer { lock.unlock() }
        
        self.classification = classification
        self.updatedAt = Date()
    }
    
    /// Updates the boundary vertices.
    ///
    /// - Parameter vertices: New boundary vertices
    public func update(boundaryVertices: [SIMD3<Float>]) {
        lock.lock()
        defer { lock.unlock() }
        
        self.boundaryVertices = boundaryVertices
        self.updatedAt = Date()
    }
    
    // MARK: - Containment
    
    /// Checks if a point is on the plane surface.
    ///
    /// - Parameters:
    ///   - point: World point to check
    ///   - tolerance: Distance tolerance
    /// - Returns: Whether point is on plane
    public func contains(point: SIMD3<Float>, tolerance: Float = 0.01) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        let localPoint = point - center
        let distanceToPlane = abs(dot(localPoint, normal))
        
        guard distanceToPlane <= tolerance else { return false }
        
        let right = SIMD3<Float>(transform.columns.0.x, transform.columns.0.y, transform.columns.0.z)
        let forward = SIMD3<Float>(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)
        
        let x = dot(localPoint, right)
        let z = dot(localPoint, forward)
        
        return abs(x) <= extent.x * 0.5 && abs(z) <= extent.z * 0.5
    }
    
    /// Projects a point onto the plane.
    ///
    /// - Parameter point: World point to project
    /// - Returns: Projected point on plane
    public func project(point: SIMD3<Float>) -> SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        
        let toPoint = point - center
        let distance = dot(toPoint, normal)
        return point - normal * distance
    }
    
    /// Gets the closest point on the plane to a given point.
    ///
    /// - Parameter point: World point
    /// - Returns: Closest point on plane surface
    public func closestPoint(to point: SIMD3<Float>) -> SIMD3<Float> {
        let projected = project(point: point)
        
        let right = SIMD3<Float>(transform.columns.0.x, transform.columns.0.y, transform.columns.0.z)
        let forward = SIMD3<Float>(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)
        
        let localPoint = projected - center
        var x = dot(localPoint, right)
        var z = dot(localPoint, forward)
        
        x = max(-extent.x * 0.5, min(extent.x * 0.5, x))
        z = max(-extent.z * 0.5, min(extent.z * 0.5, z))
        
        return center + right * x + forward * z
    }
    
    // MARK: - Distance
    
    /// Distance from a point to the plane surface.
    ///
    /// - Parameter point: World point
    /// - Returns: Distance in meters
    public func distance(to point: SIMD3<Float>) -> Float {
        let closest = closestPoint(to: point)
        return simd.distance(point, closest)
    }
    
    /// Signed distance from point to plane.
    ///
    /// - Parameter point: World point
    /// - Returns: Signed distance (positive = above plane)
    public func signedDistance(to point: SIMD3<Float>) -> Float {
        let toPoint = point - center
        return dot(toPoint, normal)
    }
    
    // MARK: - Intersection
    
    /// Ray intersection with the plane.
    ///
    /// - Parameters:
    ///   - origin: Ray origin
    ///   - direction: Ray direction (normalized)
    /// - Returns: Intersection point if any
    public func rayIntersection(origin: SIMD3<Float>, direction: SIMD3<Float>) -> SIMD3<Float>? {
        let denom = dot(direction, normal)
        
        guard abs(denom) > 0.0001 else { return nil }
        
        let t = dot(center - origin, normal) / denom
        
        guard t >= 0 else { return nil }
        
        let intersection = origin + direction * t
        
        guard contains(point: intersection) else { return nil }
        
        return intersection
    }
    
    // MARK: - Age
    
    /// Age of the anchor
    public var age: TimeInterval {
        Date().timeIntervalSince(createdAt)
    }
}

// MARK: - Plane Anchor Collection

/// A collection of plane anchors with query capabilities.
public final class PlaneAnchorCollection: @unchecked Sendable {
    
    private var planes: [UUID: PlaneAnchor] = [:]
    private let lock = NSLock()
    
    /// Creates a new collection
    public init() {}
    
    /// Adds a plane anchor
    public func add(_ plane: PlaneAnchor) {
        lock.lock()
        defer { lock.unlock() }
        planes[plane.id] = plane
    }
    
    /// Removes a plane anchor
    public func remove(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        planes.removeValue(forKey: id)
    }
    
    /// Gets all planes
    public var allPlanes: [PlaneAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return Array(planes.values)
    }
    
    /// Gets planes by alignment
    public func planes(alignment: PlaneAlignment) -> [PlaneAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return planes.values.filter { $0.alignment == alignment }
    }
    
    /// Gets planes by classification
    public func planes(classification: PlaneClassification) -> [PlaneAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return planes.values.filter { $0.classification == classification }
    }
    
    /// Gets the largest plane
    public var largestPlane: PlaneAnchor? {
        lock.lock()
        defer { lock.unlock() }
        return planes.values.max { $0.area < $1.area }
    }
    
    /// Gets plane nearest to a point
    public func nearestPlane(to point: SIMD3<Float>) -> PlaneAnchor? {
        lock.lock()
        defer { lock.unlock() }
        return planes.values.min { $0.distance(to: point) < $1.distance(to: point) }
    }
    
    /// Total area of all planes
    public var totalArea: Float {
        lock.lock()
        defer { lock.unlock() }
        return planes.values.reduce(0) { $0 + $1.area }
    }
    
    /// Clears all planes
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        planes.removeAll()
    }
}
