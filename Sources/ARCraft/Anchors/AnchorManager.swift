//
//  AnchorManager.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import Combine
import simd

#if canImport(ARKit)
import ARKit
#endif

// MARK: - Anchor State

/// Represents the tracking state of an anchor.
public enum AnchorTrackingState: String, Sendable, Equatable {
    /// Anchor is not currently being tracked
    case notTracking
    
    /// Anchor has limited tracking quality
    case limited
    
    /// Anchor is being tracked normally
    case tracking
    
    /// Description of the state
    public var description: String {
        switch self {
        case .notTracking: return "Not Tracking"
        case .limited: return "Limited"
        case .tracking: return "Tracking"
        }
    }
    
    /// Whether the anchor is usable
    public var isUsable: Bool {
        self == .tracking || self == .limited
    }
}

// MARK: - Anchor Event

/// Events that can occur with anchors.
public enum AnchorEvent: Sendable {
    /// Anchor was added
    case added(ARAnchorData)
    
    /// Anchor was updated
    case updated(ARAnchorData)
    
    /// Anchor was removed
    case removed(ARAnchorData)
    
    /// Anchor tracking state changed
    case trackingStateChanged(ARAnchorData, AnchorTrackingState)
}

// MARK: - Anchor Filter

/// Filter criteria for querying anchors.
public struct AnchorFilter: Sendable {
    /// Filter by anchor type
    public var types: Set<ARAnchorType>?
    
    /// Filter by tracking state
    public var trackingStates: Set<AnchorTrackingState>?
    
    /// Filter by name pattern
    public var namePattern: String?
    
    /// Filter by position radius
    public var nearPosition: SIMD3<Float>?
    public var maxDistance: Float?
    
    /// Creates a new filter
    public init(
        types: Set<ARAnchorType>? = nil,
        trackingStates: Set<AnchorTrackingState>? = nil,
        namePattern: String? = nil,
        nearPosition: SIMD3<Float>? = nil,
        maxDistance: Float? = nil
    ) {
        self.types = types
        self.trackingStates = trackingStates
        self.namePattern = namePattern
        self.nearPosition = nearPosition
        self.maxDistance = maxDistance
    }
    
    /// Filter for plane anchors only
    public static var planes: AnchorFilter {
        AnchorFilter(types: [.plane])
    }
    
    /// Filter for image anchors only
    public static var images: AnchorFilter {
        AnchorFilter(types: [.image])
    }
    
    /// Filter for actively tracked anchors
    public static var tracked: AnchorFilter {
        AnchorFilter(trackingStates: [.tracking])
    }
}

// MARK: - Anchor Statistics

/// Statistics about anchors in the session.
public struct AnchorStatistics: Sendable {
    /// Total number of anchors
    public let totalCount: Int
    
    /// Count by type
    public let countByType: [ARAnchorType: Int]
    
    /// Count by tracking state
    public let countByTrackingState: [AnchorTrackingState: Int]
    
    /// Average anchor age in seconds
    public let averageAge: TimeInterval
    
    /// Oldest anchor age in seconds
    public let oldestAge: TimeInterval
    
    /// Creates new statistics
    public init(
        totalCount: Int,
        countByType: [ARAnchorType: Int],
        countByTrackingState: [AnchorTrackingState: Int],
        averageAge: TimeInterval,
        oldestAge: TimeInterval
    ) {
        self.totalCount = totalCount
        self.countByType = countByType
        self.countByTrackingState = countByTrackingState
        self.averageAge = averageAge
        self.oldestAge = oldestAge
    }
}

// MARK: - Managed Anchor

/// An anchor with additional management metadata.
public final class ManagedAnchor: Identifiable, @unchecked Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Underlying anchor data
    public private(set) var data: ARAnchorData
    
    /// Current tracking state
    public private(set) var trackingState: AnchorTrackingState
    
    /// When the anchor was created
    public let createdAt: Date
    
    /// When the anchor was last updated
    public private(set) var updatedAt: Date
    
    /// Associated entities
    public var associatedEntities: [UUID] = []
    
    /// Custom user data
    public var userData: [String: Any] = [:]
    
    /// Whether the anchor should persist across sessions
    public var isPersistent: Bool = false
    
    /// Priority for resource allocation
    public var priority: Int = 0
    
    private let lock = NSLock()
    
    /// Creates a new managed anchor
    public init(data: ARAnchorData, trackingState: AnchorTrackingState = .tracking) {
        self.id = data.id
        self.data = data
        self.trackingState = trackingState
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Updates the anchor data
    public func update(data: ARAnchorData) {
        lock.lock()
        defer { lock.unlock() }
        self.data = data
        self.updatedAt = Date()
    }
    
    /// Updates the tracking state
    public func update(trackingState: AnchorTrackingState) {
        lock.lock()
        defer { lock.unlock() }
        self.trackingState = trackingState
        self.updatedAt = Date()
    }
    
    /// Age of the anchor in seconds
    public var age: TimeInterval {
        Date().timeIntervalSince(createdAt)
    }
    
    /// Time since last update in seconds
    public var timeSinceUpdate: TimeInterval {
        Date().timeIntervalSince(updatedAt)
    }
}

// MARK: - Anchor Manager Delegate

/// Protocol for receiving anchor manager events.
public protocol AnchorManagerDelegate: AnyObject {
    /// Called when an anchor event occurs
    func anchorManager(_ manager: AnchorManager, didReceiveEvent event: AnchorEvent)
    
    /// Called when anchor statistics are updated
    func anchorManager(_ manager: AnchorManager, didUpdateStatistics statistics: AnchorStatistics)
}

public extension AnchorManagerDelegate {
    func anchorManager(_ manager: AnchorManager, didReceiveEvent event: AnchorEvent) {}
    func anchorManager(_ manager: AnchorManager, didUpdateStatistics statistics: AnchorStatistics) {}
}

// MARK: - Anchor Manager

/// Manages AR anchors for the session.
///
/// `AnchorManager` provides comprehensive anchor management including
/// creation, tracking, querying, and lifecycle management.
///
/// ## Example
///
/// ```swift
/// let manager = AnchorManager()
///
/// // Add an anchor
/// let anchor = manager.createWorldAnchor(at: position)
///
/// // Query anchors
/// let planes = manager.query(filter: .planes)
///
/// // Listen to events
/// manager.eventPublisher
///     .sink { event in
///         print("Anchor event: \(event)")
///     }
/// ```
public final class AnchorManager: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Delegate for receiving events
    public weak var delegate: AnchorManagerDelegate?
    
    /// Publisher for anchor events
    public let eventPublisher = PassthroughSubject<AnchorEvent, Never>()
    
    /// All managed anchors
    private var anchors: [UUID: ManagedAnchor] = [:]
    
    /// Anchors by type for fast lookup
    private var anchorsByType: [ARAnchorType: Set<UUID>] = [:]
    
    /// Maximum number of anchors to maintain
    public var maxAnchorCount: Int = 100
    
    /// Whether to automatically prune old anchors
    public var autoPruning: Bool = true
    
    /// Maximum age for auto-pruned anchors
    public var maxAnchorAge: TimeInterval = 300
    
    private let lock = NSLock()
    private var pruningTimer: Timer?
    
    // MARK: - Initialization
    
    /// Creates a new anchor manager.
    public init() {
        setupPruningTimer()
    }
    
    deinit {
        pruningTimer?.invalidate()
    }
    
    private func setupPruningTimer() {
        pruningTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.performAutoPruning()
        }
    }
    
    // MARK: - Anchor Creation
    
    /// Creates a world anchor at the specified position.
    ///
    /// - Parameters:
    ///   - position: World position for the anchor
    ///   - name: Optional name for the anchor
    /// - Returns: The created managed anchor
    @discardableResult
    public func createWorldAnchor(at position: SIMD3<Float>, name: String? = nil) -> ManagedAnchor {
        let transform = simd_float4x4(translation: position)
        let data = ARAnchorData(name: name, transform: transform, type: .world)
        return addAnchor(data: data)
    }
    
    /// Creates an anchor with a full transform.
    ///
    /// - Parameters:
    ///   - transform: World transform for the anchor
    ///   - type: Type of anchor
    ///   - name: Optional name for the anchor
    /// - Returns: The created managed anchor
    @discardableResult
    public func createAnchor(transform: simd_float4x4, type: ARAnchorType, name: String? = nil) -> ManagedAnchor {
        let data = ARAnchorData(name: name, transform: transform, type: type)
        return addAnchor(data: data)
    }
    
    /// Creates a plane anchor.
    ///
    /// - Parameters:
    ///   - center: Center position of the plane
    ///   - extent: Size of the plane
    ///   - alignment: Plane alignment
    ///   - name: Optional name
    /// - Returns: The created managed anchor
    @discardableResult
    public func createPlaneAnchor(
        center: SIMD3<Float>,
        extent: SIMD3<Float>,
        alignment: PlaneAnchor.Alignment,
        name: String? = nil
    ) -> ManagedAnchor {
        let transform = simd_float4x4(translation: center)
        let data = ARAnchorData(name: name, transform: transform, type: .plane)
        let anchor = addAnchor(data: data)
        anchor.userData["extent"] = extent
        anchor.userData["alignment"] = alignment.rawValue
        return anchor
    }
    
    // MARK: - Anchor Management
    
    /// Adds an anchor from raw data.
    ///
    /// - Parameter data: The anchor data to add
    /// - Returns: The created managed anchor
    @discardableResult
    public func addAnchor(data: ARAnchorData) -> ManagedAnchor {
        lock.lock()
        defer { lock.unlock() }
        
        let managed = ManagedAnchor(data: data)
        anchors[managed.id] = managed
        
        if anchorsByType[data.type] == nil {
            anchorsByType[data.type] = []
        }
        anchorsByType[data.type]?.insert(managed.id)
        
        let event = AnchorEvent.added(data)
        eventPublisher.send(event)
        delegate?.anchorManager(self, didReceiveEvent: event)
        
        checkAnchorLimit()
        
        return managed
    }
    
    /// Updates an existing anchor.
    ///
    /// - Parameter data: Updated anchor data
    public func updateAnchor(data: ARAnchorData) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let anchor = anchors[data.id] else { return }
        anchor.update(data: data)
        
        let event = AnchorEvent.updated(data)
        eventPublisher.send(event)
        delegate?.anchorManager(self, didReceiveEvent: event)
    }
    
    /// Removes an anchor by ID.
    ///
    /// - Parameter id: ID of the anchor to remove
    public func removeAnchor(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let anchor = anchors.removeValue(forKey: id) else { return }
        anchorsByType[anchor.data.type]?.remove(id)
        
        let event = AnchorEvent.removed(anchor.data)
        eventPublisher.send(event)
        delegate?.anchorManager(self, didReceiveEvent: event)
    }
    
    /// Removes all anchors.
    public func removeAllAnchors() {
        lock.lock()
        defer { lock.unlock() }
        
        let allAnchors = Array(anchors.values)
        anchors.removeAll()
        anchorsByType.removeAll()
        
        for anchor in allAnchors {
            let event = AnchorEvent.removed(anchor.data)
            eventPublisher.send(event)
            delegate?.anchorManager(self, didReceiveEvent: event)
        }
    }
    
    // MARK: - Anchor Querying
    
    /// Gets an anchor by ID.
    ///
    /// - Parameter id: The anchor ID
    /// - Returns: The managed anchor if found
    public func anchor(for id: UUID) -> ManagedAnchor? {
        lock.lock()
        defer { lock.unlock() }
        return anchors[id]
    }
    
    /// Gets all anchors.
    ///
    /// - Returns: Array of all managed anchors
    public var allAnchors: [ManagedAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return Array(anchors.values)
    }
    
    /// Number of anchors.
    public var anchorCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return anchors.count
    }
    
    /// Queries anchors with a filter.
    ///
    /// - Parameter filter: Filter criteria
    /// - Returns: Array of matching anchors
    public func query(filter: AnchorFilter) -> [ManagedAnchor] {
        lock.lock()
        defer { lock.unlock() }
        
        var result = Array(anchors.values)
        
        if let types = filter.types {
            result = result.filter { types.contains($0.data.type) }
        }
        
        if let states = filter.trackingStates {
            result = result.filter { states.contains($0.trackingState) }
        }
        
        if let pattern = filter.namePattern {
            result = result.filter { anchor in
                guard let name = anchor.data.name else { return false }
                return name.contains(pattern)
            }
        }
        
        if let position = filter.nearPosition, let maxDist = filter.maxDistance {
            result = result.filter { anchor in
                distance(anchor.data.position, position) <= maxDist
            }
        }
        
        return result
    }
    
    /// Finds anchors of a specific type.
    ///
    /// - Parameter type: The anchor type
    /// - Returns: Array of matching anchors
    public func anchors(ofType type: ARAnchorType) -> [ManagedAnchor] {
        lock.lock()
        defer { lock.unlock() }
        
        guard let ids = anchorsByType[type] else { return [] }
        return ids.compactMap { anchors[$0] }
    }
    
    /// Finds the nearest anchor to a position.
    ///
    /// - Parameters:
    ///   - position: Reference position
    ///   - type: Optional type filter
    /// - Returns: The nearest anchor if any
    public func nearestAnchor(to position: SIMD3<Float>, ofType type: ARAnchorType? = nil) -> ManagedAnchor? {
        lock.lock()
        defer { lock.unlock() }
        
        var candidates = Array(anchors.values)
        if let type = type {
            candidates = candidates.filter { $0.data.type == type }
        }
        
        return candidates.min { anchor1, anchor2 in
            let dist1 = distance(anchor1.data.position, position)
            let dist2 = distance(anchor2.data.position, position)
            return dist1 < dist2
        }
    }
    
    /// Finds anchors within a radius.
    ///
    /// - Parameters:
    ///   - position: Center position
    ///   - radius: Search radius
    /// - Returns: Array of anchors within radius
    public func anchors(within radius: Float, of position: SIMD3<Float>) -> [ManagedAnchor] {
        lock.lock()
        defer { lock.unlock() }
        
        return anchors.values.filter { anchor in
            distance(anchor.data.position, position) <= radius
        }
    }
    
    // MARK: - Tracking State
    
    /// Updates the tracking state for an anchor.
    ///
    /// - Parameters:
    ///   - id: Anchor ID
    ///   - state: New tracking state
    public func updateTrackingState(for id: UUID, state: AnchorTrackingState) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let anchor = anchors[id] else { return }
        let oldState = anchor.trackingState
        anchor.update(trackingState: state)
        
        if oldState != state {
            let event = AnchorEvent.trackingStateChanged(anchor.data, state)
            eventPublisher.send(event)
            delegate?.anchorManager(self, didReceiveEvent: event)
        }
    }
    
    // MARK: - Statistics
    
    /// Computes current anchor statistics.
    ///
    /// - Returns: Current statistics
    public func computeStatistics() -> AnchorStatistics {
        lock.lock()
        defer { lock.unlock() }
        
        var countByType: [ARAnchorType: Int] = [:]
        var countByState: [AnchorTrackingState: Int] = [:]
        var totalAge: TimeInterval = 0
        var oldestAge: TimeInterval = 0
        
        for anchor in anchors.values {
            countByType[anchor.data.type, default: 0] += 1
            countByState[anchor.trackingState, default: 0] += 1
            
            let age = anchor.age
            totalAge += age
            oldestAge = max(oldestAge, age)
        }
        
        let averageAge = anchors.isEmpty ? 0 : totalAge / Double(anchors.count)
        
        return AnchorStatistics(
            totalCount: anchors.count,
            countByType: countByType,
            countByTrackingState: countByState,
            averageAge: averageAge,
            oldestAge: oldestAge
        )
    }
    
    // MARK: - Pruning
    
    private func checkAnchorLimit() {
        guard anchors.count > maxAnchorCount else { return }
        
        let toRemove = anchors.count - maxAnchorCount
        let sorted = anchors.values.sorted { $0.priority < $1.priority }
        
        for anchor in sorted.prefix(toRemove) {
            if !anchor.isPersistent {
                anchors.removeValue(forKey: anchor.id)
                anchorsByType[anchor.data.type]?.remove(anchor.id)
            }
        }
    }
    
    private func performAutoPruning() {
        guard autoPruning else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        let now = Date()
        var toRemove: [UUID] = []
        
        for anchor in anchors.values {
            if !anchor.isPersistent && anchor.age > maxAnchorAge {
                if anchor.trackingState != .tracking {
                    toRemove.append(anchor.id)
                }
            }
        }
        
        for id in toRemove {
            if let anchor = anchors.removeValue(forKey: id) {
                anchorsByType[anchor.data.type]?.remove(id)
                
                let event = AnchorEvent.removed(anchor.data)
                eventPublisher.send(event)
            }
        }
    }
    
    // MARK: - Persistence
    
    /// Marks an anchor as persistent.
    ///
    /// - Parameter id: Anchor ID
    public func markPersistent(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        anchors[id]?.isPersistent = true
    }
    
    /// Marks an anchor as not persistent.
    ///
    /// - Parameter id: Anchor ID
    public func markTransient(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        anchors[id]?.isPersistent = false
    }
    
    /// Gets all persistent anchors.
    ///
    /// - Returns: Array of persistent anchors
    public var persistentAnchors: [ManagedAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return anchors.values.filter { $0.isPersistent }
    }
    
    // MARK: - Entity Association
    
    /// Associates an entity with an anchor.
    ///
    /// - Parameters:
    ///   - entityID: Entity ID to associate
    ///   - anchorID: Anchor ID
    public func associateEntity(_ entityID: UUID, with anchorID: UUID) {
        lock.lock()
        defer { lock.unlock() }
        anchors[anchorID]?.associatedEntities.append(entityID)
    }
    
    /// Removes entity association from an anchor.
    ///
    /// - Parameters:
    ///   - entityID: Entity ID to remove
    ///   - anchorID: Anchor ID
    public func removeEntityAssociation(_ entityID: UUID, from anchorID: UUID) {
        lock.lock()
        defer { lock.unlock() }
        anchors[anchorID]?.associatedEntities.removeAll { $0 == entityID }
    }
    
    /// Gets anchors associated with an entity.
    ///
    /// - Parameter entityID: Entity ID
    /// - Returns: Array of associated anchors
    public func anchors(for entityID: UUID) -> [ManagedAnchor] {
        lock.lock()
        defer { lock.unlock() }
        return anchors.values.filter { $0.associatedEntities.contains(entityID) }
    }
}

// MARK: - Matrix Extension

extension simd_float4x4 {
    /// Creates a translation matrix.
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)
    }
}
