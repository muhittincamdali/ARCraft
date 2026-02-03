//
//  ObjectAnchor.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Object Reference

/// Reference object for 3D object detection.
public struct ObjectReference: Identifiable, Hashable, Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Name of the reference object
    public let name: String
    
    /// Center of the object's bounding box in reference frame
    public let center: SIMD3<Float>
    
    /// Extent of the object's bounding box
    public let extent: SIMD3<Float>
    
    /// Resource name or path
    public let resourceName: String?
    
    /// Creates a new object reference
    public init(
        name: String,
        center: SIMD3<Float>,
        extent: SIMD3<Float>,
        resourceName: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.center = center
        self.extent = extent
        self.resourceName = resourceName
    }
    
    /// Volume of the bounding box
    public var volume: Float {
        extent.x * extent.y * extent.z
    }
    
    /// Diagonal length of the bounding box
    public var diagonal: Float {
        length(extent)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ObjectReference, rhs: ObjectReference) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Object Tracking State

/// Tracking state for object anchors.
public enum ObjectTrackingState: String, Sendable, Equatable {
    /// Object is being tracked
    case tracking
    
    /// Object tracking is limited
    case limited
    
    /// Object was lost
    case lost
    
    /// Object is not being tracked
    case notTracking
    
    /// Description
    public var description: String {
        switch self {
        case .tracking: return "Tracking"
        case .limited: return "Limited"
        case .lost: return "Lost"
        case .notTracking: return "Not Tracking"
        }
    }
}

// MARK: - Object Anchor

/// Represents an anchor for a detected 3D object.
///
/// `ObjectAnchor` tracks real-world objects using pre-scanned reference
/// objects, providing position, orientation, and bounding box information.
///
/// ## Example
///
/// ```swift
/// let reference = ObjectReference(
///     name: "coffee_cup",
///     center: .zero,
///     extent: SIMD3<Float>(0.08, 0.12, 0.08)
/// )
///
/// let anchor = ObjectAnchor(reference: reference, transform: detectedTransform)
///
/// // Check tracking state
/// if anchor.trackingState == .tracking {
///     // Object is actively tracked
///     let bounds = anchor.worldBoundingBox
/// }
/// ```
public final class ObjectAnchor: Identifiable, @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Unique identifier
    public let id: UUID
    
    /// Reference object this anchor is tracking
    public let reference: ObjectReference
    
    /// World transform of the detected object
    public private(set) var transform: simd_float4x4
    
    /// Current tracking state
    public private(set) var trackingState: ObjectTrackingState
    
    /// Detection confidence (0-1)
    public private(set) var confidence: Float
    
    /// Estimated scale relative to reference
    public private(set) var estimatedScale: SIMD3<Float>
    
    /// Creation timestamp
    public let createdAt: Date
    
    /// Last update timestamp
    public private(set) var updatedAt: Date
    
    /// User data
    public var userData: [String: Any] = [:]
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a new object anchor.
    ///
    /// - Parameters:
    ///   - reference: Reference object being tracked
    ///   - transform: World transform of detected object
    ///   - trackingState: Initial tracking state
    public init(
        reference: ObjectReference,
        transform: simd_float4x4,
        trackingState: ObjectTrackingState = .tracking
    ) {
        self.id = UUID()
        self.reference = reference
        self.transform = transform
        self.trackingState = trackingState
        self.confidence = 1.0
        self.estimatedScale = SIMD3<Float>(1, 1, 1)
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Position
    
    /// World position of the object
    public var position: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        return SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }
    
    /// Forward direction of the object
    public var forward: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        return normalize(SIMD3<Float>(
            -transform.columns.2.x,
            -transform.columns.2.y,
            -transform.columns.2.z
        ))
    }
    
    /// Up direction of the object
    public var up: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        return normalize(SIMD3<Float>(
            transform.columns.1.x,
            transform.columns.1.y,
            transform.columns.1.z
        ))
    }
    
    /// Right direction of the object
    public var right: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        return normalize(SIMD3<Float>(
            transform.columns.0.x,
            transform.columns.0.y,
            transform.columns.0.z
        ))
    }
    
    // MARK: - Bounding Box
    
    /// Scaled extent of the detected object
    public var scaledExtent: SIMD3<Float> {
        reference.extent * estimatedScale
    }
    
    /// World-space bounding box of the object
    public var worldBoundingBox: (min: SIMD3<Float>, max: SIMD3<Float>) {
        let halfExtent = scaledExtent * 0.5
        let center = position + reference.center * estimatedScale
        return (
            min: center - halfExtent,
            max: center + halfExtent
        )
    }
    
    /// Corners of the bounding box in world space
    public var boundingBoxCorners: [SIMD3<Float>] {
        let half = scaledExtent * 0.5
        let offsets: [SIMD3<Float>] = [
            SIMD3(-half.x, -half.y, -half.z),
            SIMD3(half.x, -half.y, -half.z),
            SIMD3(half.x, half.y, -half.z),
            SIMD3(-half.x, half.y, -half.z),
            SIMD3(-half.x, -half.y, half.z),
            SIMD3(half.x, -half.y, half.z),
            SIMD3(half.x, half.y, half.z),
            SIMD3(-half.x, half.y, half.z)
        ]
        
        return offsets.map { offset in
            position + right * offset.x + up * offset.y + forward * offset.z
        }
    }
    
    // MARK: - Updates
    
    /// Updates the object anchor.
    ///
    /// - Parameters:
    ///   - transform: New transform
    ///   - trackingState: New tracking state
    ///   - confidence: Detection confidence
    ///   - scale: Estimated scale
    public func update(
        transform: simd_float4x4,
        trackingState: ObjectTrackingState,
        confidence: Float = 1.0,
        scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        self.transform = transform
        self.trackingState = trackingState
        self.confidence = confidence
        self.estimatedScale = scale
        self.updatedAt = Date()
    }
    
    /// Updates only tracking state
    public func updateTrackingState(_ state: ObjectTrackingState) {
        lock.lock()
        defer { lock.unlock() }
        
        self.trackingState = state
        self.updatedAt = Date()
    }
    
    // MARK: - Containment
    
    /// Checks if a point is inside the object's bounding box.
    ///
    /// - Parameter point: World point to check
    /// - Returns: Whether point is inside
    public func contains(point: SIMD3<Float>) -> Bool {
        let localPoint = point - position
        
        let x = abs(dot(localPoint, right))
        let y = abs(dot(localPoint, up))
        let z = abs(dot(localPoint, forward))
        
        let half = scaledExtent * 0.5
        
        return x <= half.x && y <= half.y && z <= half.z
    }
    
    /// Distance from point to the object's surface.
    ///
    /// - Parameter point: World point
    /// - Returns: Distance in meters (negative if inside)
    public func distance(to point: SIMD3<Float>) -> Float {
        let bounds = worldBoundingBox
        
        let clamped = SIMD3<Float>(
            max(bounds.min.x, min(bounds.max.x, point.x)),
            max(bounds.min.y, min(bounds.max.y, point.y)),
            max(bounds.min.z, min(bounds.max.z, point.z))
        )
        
        return simd.distance(point, clamped)
    }
    
    // MARK: - Ray Intersection
    
    /// Ray intersection with the object's bounding box.
    ///
    /// - Parameters:
    ///   - origin: Ray origin
    ///   - direction: Ray direction
    /// - Returns: Intersection distance if any
    public func rayIntersection(origin: SIMD3<Float>, direction: SIMD3<Float>) -> Float? {
        let bounds = worldBoundingBox
        
        var tMin: Float = 0
        var tMax: Float = Float.greatestFiniteMagnitude
        
        for i in 0..<3 {
            let bMin = bounds.min[i]
            let bMax = bounds.max[i]
            let o = origin[i]
            let d = direction[i]
            
            if abs(d) < 0.0001 {
                if o < bMin || o > bMax {
                    return nil
                }
            } else {
                var t1 = (bMin - o) / d
                var t2 = (bMax - o) / d
                
                if t1 > t2 {
                    swap(&t1, &t2)
                }
                
                tMin = max(tMin, t1)
                tMax = min(tMax, t2)
                
                if tMin > tMax {
                    return nil
                }
            }
        }
        
        return tMin
    }
    
    // MARK: - State
    
    /// Whether the object is actively tracked
    public var isTracked: Bool {
        trackingState == .tracking
    }
    
    /// Age of the anchor
    public var age: TimeInterval {
        Date().timeIntervalSince(createdAt)
    }
    
    /// Time since last update
    public var timeSinceUpdate: TimeInterval {
        Date().timeIntervalSince(updatedAt)
    }
}

// MARK: - Object Anchor Manager

/// Manages object anchors for object tracking experiences.
public final class ObjectAnchorManager: @unchecked Sendable {
    
    // MARK: - Properties
    
    private var anchors: [UUID: ObjectAnchor] = [:]
    private var anchorsByName: [String: UUID] = [:]
    
    /// Reference objects being tracked
    public private(set) var references: [ObjectReference] = []
    
    /// Maximum number of objects to track
    public var maxTrackedObjects: Int = 10
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a new object anchor manager
    public init() {}
    
    // MARK: - Reference Management
    
    /// Adds a reference object to track
    public func addReference(_ reference: ObjectReference) {
        lock.lock()
        defer { lock.unlock() }
        references.append(reference)
    }
    
    /// Removes a reference object
    public func removeReference(named name: String) {
        lock.lock()
        defer { lock.unlock() }
        references.removeAll { $0.name == name }
    }
    
    /// Clears all reference objects
    public func clearReferences() {
        lock.lock()
        defer { lock.unlock() }
        references.removeAll()
    }
    
    // MARK: - Anchor Management
    
    /// Creates or updates an anchor for a detected object
    @discardableResult
    public func updateAnchor(
        for reference: ObjectReference,
        transform: simd_float4x4,
        confidence: Float = 1.0
    ) -> ObjectAnchor {
        lock.lock()
        defer { lock.unlock() }
        
        if let existingID = anchorsByName[reference.name],
           let existing = anchors[existingID] {
            existing.update(
                transform: transform,
                trackingState: .tracking,
                confidence: confidence
            )
            return existing
        }
        
        let anchor = ObjectAnchor(reference: reference, transform: transform)
        anchors[anchor.id] = anchor
        anchorsByName[reference.name] = anchor.id
        return anchor
    }
    
    /// Gets an anchor by reference name
    public func anchor(for name: String) -> ObjectAnchor? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let id = anchorsByName[name] else { return nil }
        return anchors[id]
    }
    
    /// Gets all tracked anchors
    public var trackedAnchors: [ObjectAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return anchors.values.filter { $0.isTracked }
    }
    
    /// Gets all anchors
    public var allAnchors: [ObjectAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return Array(anchors.values)
    }
    
    /// Marks an anchor as lost
    public func markLost(name: String) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let id = anchorsByName[name] else { return }
        anchors[id]?.updateTrackingState(.lost)
    }
    
    /// Removes an anchor
    public func removeAnchor(named name: String) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let id = anchorsByName.removeValue(forKey: name) else { return }
        anchors.removeValue(forKey: id)
    }
    
    /// Clears all anchors
    public func clearAnchors() {
        lock.lock()
        defer { lock.unlock() }
        anchors.removeAll()
        anchorsByName.removeAll()
    }
}
