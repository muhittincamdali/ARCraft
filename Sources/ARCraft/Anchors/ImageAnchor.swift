//
//  ImageAnchor.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

#if canImport(CoreGraphics)
import CoreGraphics
#endif

// MARK: - Image Anchor State

/// Tracking state specific to image anchors.
public enum ImageAnchorTrackingState: String, Sendable, Equatable {
    /// Image is currently being tracked
    case tracking
    
    /// Image was previously tracked but is not visible
    case limited
    
    /// Image tracking is paused
    case paused
    
    /// Image is not being tracked
    case notTracking
    
    /// Description
    public var description: String {
        switch self {
        case .tracking: return "Tracking"
        case .limited: return "Limited"
        case .paused: return "Paused"
        case .notTracking: return "Not Tracking"
        }
    }
    
    /// Whether content should be visible
    public var shouldShowContent: Bool {
        self == .tracking || self == .limited
    }
}

// MARK: - Image Reference

/// Reference image for tracking.
public struct ImageReference: Identifiable, Hashable, Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Name of the reference image
    public let name: String
    
    /// Physical width of the image in meters
    public let physicalWidth: Float
    
    /// Physical height of the image in meters (optional)
    public let physicalHeight: Float?
    
    /// Resource name or path
    public let resourceName: String?
    
    /// Group this image belongs to
    public let group: String?
    
    /// Creates a new image reference
    public init(
        name: String,
        physicalWidth: Float,
        physicalHeight: Float? = nil,
        resourceName: String? = nil,
        group: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.physicalWidth = physicalWidth
        self.physicalHeight = physicalHeight
        self.resourceName = resourceName
        self.group = group
    }
    
    /// Aspect ratio of the image
    public var aspectRatio: Float? {
        guard let height = physicalHeight else { return nil }
        return physicalWidth / height
    }
    
    /// Physical size as a 2D vector
    public var physicalSize: SIMD2<Float> {
        SIMD2<Float>(physicalWidth, physicalHeight ?? physicalWidth)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ImageReference, rhs: ImageReference) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Image Anchor

/// Represents an anchor attached to a detected reference image.
///
/// `ImageAnchor` provides position and orientation information for
/// tracked reference images, allowing you to place virtual content
/// relative to physical images.
///
/// ## Example
///
/// ```swift
/// let reference = ImageReference(
///     name: "poster",
///     physicalWidth: 0.3
/// )
///
/// let anchor = ImageAnchor(reference: reference, transform: transform)
///
/// if anchor.trackingState == .tracking {
///     // Place content relative to image
///     let content = ModelEntity()
///     content.transform = anchor.contentTransform
/// }
/// ```
public final class ImageAnchor: Identifiable, @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Unique identifier for this anchor
    public let id: UUID
    
    /// Reference image this anchor is tracking
    public let reference: ImageReference
    
    /// Current transform of the image in world space
    public private(set) var transform: simd_float4x4
    
    /// Current tracking state
    public private(set) var trackingState: ImageAnchorTrackingState
    
    /// Whether the image is currently being tracked
    public var isTracked: Bool {
        trackingState == .tracking
    }
    
    /// Estimated scale of the detected image relative to reference
    public private(set) var estimatedScale: Float
    
    /// Confidence of the detection (0-1)
    public private(set) var confidence: Float
    
    /// When the anchor was created
    public let createdAt: Date
    
    /// When the anchor was last updated
    public private(set) var updatedAt: Date
    
    /// User data attached to this anchor
    public var userData: [String: Any] = [:]
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a new image anchor.
    ///
    /// - Parameters:
    ///   - reference: The reference image being tracked
    ///   - transform: Initial world transform
    ///   - trackingState: Initial tracking state
    public init(
        reference: ImageReference,
        transform: simd_float4x4,
        trackingState: ImageAnchorTrackingState = .tracking
    ) {
        self.id = UUID()
        self.reference = reference
        self.transform = transform
        self.trackingState = trackingState
        self.estimatedScale = 1.0
        self.confidence = 1.0
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Position Properties
    
    /// World position of the image center
    public var position: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        return SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }
    
    /// Forward direction of the image (normal to the surface)
    public var forward: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        return normalize(SIMD3<Float>(
            -transform.columns.2.x,
            -transform.columns.2.y,
            -transform.columns.2.z
        ))
    }
    
    /// Up direction of the image
    public var up: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        return normalize(SIMD3<Float>(
            transform.columns.1.x,
            transform.columns.1.y,
            transform.columns.1.z
        ))
    }
    
    /// Right direction of the image
    public var right: SIMD3<Float> {
        lock.lock()
        defer { lock.unlock() }
        return normalize(SIMD3<Float>(
            transform.columns.0.x,
            transform.columns.0.y,
            transform.columns.0.z
        ))
    }
    
    // MARK: - Extent Properties
    
    /// Physical extent of the detected image
    public var extent: SIMD3<Float> {
        let scaledWidth = reference.physicalWidth * estimatedScale
        let scaledHeight = (reference.physicalHeight ?? reference.physicalWidth) * estimatedScale
        return SIMD3<Float>(scaledWidth, 0.001, scaledHeight)
    }
    
    /// Half extents for bounds calculations
    public var halfExtent: SIMD3<Float> {
        extent * 0.5
    }
    
    // MARK: - Content Placement
    
    /// Transform for placing content on top of the image
    public var contentTransform: simd_float4x4 {
        lock.lock()
        defer { lock.unlock() }
        
        var result = transform
        result.columns.3.y += 0.001
        return result
    }
    
    /// Position offset from center by given factors
    public func offsetPosition(x: Float, y: Float) -> SIMD3<Float> {
        let halfWidth = reference.physicalWidth * estimatedScale * 0.5
        let halfHeight = (reference.physicalHeight ?? reference.physicalWidth) * estimatedScale * 0.5
        
        return position + right * (x * halfWidth) + up * (y * halfHeight)
    }
    
    /// Gets corner positions of the image
    public var corners: [SIMD3<Float>] {
        [
            offsetPosition(x: -1, y: -1),
            offsetPosition(x: 1, y: -1),
            offsetPosition(x: 1, y: 1),
            offsetPosition(x: -1, y: 1)
        ]
    }
    
    // MARK: - Updates
    
    /// Updates the anchor with new tracking data.
    ///
    /// - Parameters:
    ///   - transform: New world transform
    ///   - trackingState: New tracking state
    ///   - scale: Estimated scale
    ///   - confidence: Detection confidence
    public func update(
        transform: simd_float4x4,
        trackingState: ImageAnchorTrackingState,
        scale: Float = 1.0,
        confidence: Float = 1.0
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        self.transform = transform
        self.trackingState = trackingState
        self.estimatedScale = scale
        self.confidence = confidence
        self.updatedAt = Date()
    }
    
    /// Updates only the tracking state.
    ///
    /// - Parameter state: New tracking state
    public func updateTrackingState(_ state: ImageAnchorTrackingState) {
        lock.lock()
        defer { lock.unlock() }
        
        self.trackingState = state
        self.updatedAt = Date()
    }
    
    // MARK: - Distance
    
    /// Calculates distance to a world point.
    ///
    /// - Parameter point: World point
    /// - Returns: Distance in meters
    public func distance(to point: SIMD3<Float>) -> Float {
        simd.distance(position, point)
    }
    
    /// Checks if a point is within the image bounds.
    ///
    /// - Parameter point: World point
    /// - Returns: Whether the point is over the image
    public func contains(point: SIMD3<Float>) -> Bool {
        let localPoint = point - position
        let x = dot(localPoint, right)
        let z = dot(localPoint, forward)
        
        let halfWidth = reference.physicalWidth * estimatedScale * 0.5
        let halfHeight = (reference.physicalHeight ?? reference.physicalWidth) * estimatedScale * 0.5
        
        return abs(x) <= halfWidth && abs(z) <= halfHeight
    }
    
    // MARK: - Age
    
    /// Age of the anchor in seconds
    public var age: TimeInterval {
        Date().timeIntervalSince(createdAt)
    }
    
    /// Time since last update in seconds
    public var timeSinceUpdate: TimeInterval {
        Date().timeIntervalSince(updatedAt)
    }
}

// MARK: - Image Anchor Manager

/// Manages multiple image anchors for image tracking experiences.
public final class ImageAnchorManager: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// All tracked image anchors
    private var anchors: [UUID: ImageAnchor] = [:]
    
    /// Anchors indexed by reference name
    private var anchorsByName: [String: UUID] = [:]
    
    /// Reference images being tracked
    public private(set) var references: [ImageReference] = []
    
    /// Maximum number of images to track simultaneously
    public var maxTrackedImages: Int = 4
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a new image anchor manager.
    public init() {}
    
    // MARK: - Reference Management
    
    /// Adds a reference image to track.
    ///
    /// - Parameter reference: Reference image to add
    public func addReference(_ reference: ImageReference) {
        lock.lock()
        defer { lock.unlock() }
        references.append(reference)
    }
    
    /// Removes a reference image.
    ///
    /// - Parameter name: Name of the reference to remove
    public func removeReference(named name: String) {
        lock.lock()
        defer { lock.unlock() }
        references.removeAll { $0.name == name }
    }
    
    /// Clears all reference images.
    public func clearReferences() {
        lock.lock()
        defer { lock.unlock() }
        references.removeAll()
    }
    
    // MARK: - Anchor Management
    
    /// Creates or updates an anchor for a detected image.
    ///
    /// - Parameters:
    ///   - reference: Detected reference image
    ///   - transform: World transform
    /// - Returns: The image anchor
    @discardableResult
    public func updateAnchor(
        for reference: ImageReference,
        transform: simd_float4x4
    ) -> ImageAnchor {
        lock.lock()
        defer { lock.unlock() }
        
        if let existingID = anchorsByName[reference.name],
           let existing = anchors[existingID] {
            existing.update(
                transform: transform,
                trackingState: .tracking
            )
            return existing
        }
        
        let anchor = ImageAnchor(
            reference: reference,
            transform: transform
        )
        anchors[anchor.id] = anchor
        anchorsByName[reference.name] = anchor.id
        return anchor
    }
    
    /// Gets an anchor by reference name.
    ///
    /// - Parameter name: Reference name
    /// - Returns: The anchor if found
    public func anchor(for name: String) -> ImageAnchor? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let id = anchorsByName[name] else { return nil }
        return anchors[id]
    }
    
    /// Gets all currently tracked anchors.
    public var trackedAnchors: [ImageAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return anchors.values.filter { $0.isTracked }
    }
    
    /// Gets all anchors.
    public var allAnchors: [ImageAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return Array(anchors.values)
    }
    
    /// Marks an anchor as not tracking.
    ///
    /// - Parameter name: Reference name
    public func markNotTracking(name: String) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let id = anchorsByName[name] else { return }
        anchors[id]?.updateTrackingState(.notTracking)
    }
    
    /// Removes an anchor.
    ///
    /// - Parameter name: Reference name
    public func removeAnchor(named name: String) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let id = anchorsByName.removeValue(forKey: name) else { return }
        anchors.removeValue(forKey: id)
    }
    
    /// Removes all anchors.
    public func clearAnchors() {
        lock.lock()
        defer { lock.unlock() }
        anchors.removeAll()
        anchorsByName.removeAll()
    }
}
