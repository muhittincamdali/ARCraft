//
//  WorldMap.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - World Map State

/// State of a world map.
public enum WorldMapState: String, Sendable, CaseIterable {
    /// Map is not available
    case notAvailable
    
    /// Map is being collected
    case extending
    
    /// Map has limited coverage
    case limited
    
    /// Map is fully mapped
    case mapped
    
    /// Description
    public var description: String {
        switch self {
        case .notAvailable: return "Not Available"
        case .extending: return "Extending"
        case .limited: return "Limited"
        case .mapped: return "Mapped"
        }
    }
    
    /// Whether the map is usable for relocation
    public var isUsable: Bool {
        self == .mapped || self == .limited
    }
}

// MARK: - Persistent Anchor

/// An anchor that can be persisted and restored.
public struct PersistentAnchor: Codable, Identifiable, Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Name of the anchor
    public let name: String
    
    /// Transform as array (for codability)
    private let transformArray: [Float]
    
    /// Anchor type
    public let type: String
    
    /// Creation timestamp
    public let createdAt: Date
    
    /// Custom metadata
    public let metadata: [String: String]
    
    /// World transform
    public var transform: simd_float4x4 {
        var matrix = simd_float4x4()
        for i in 0..<16 {
            let row = i / 4
            let col = i % 4
            matrix[col][row] = transformArray[i]
        }
        return matrix
    }
    
    /// Creates a persistent anchor
    public init(
        id: UUID = UUID(),
        name: String,
        transform: simd_float4x4,
        type: ARAnchorType,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.type = type.rawValue
        self.createdAt = Date()
        self.metadata = metadata
        
        var array: [Float] = []
        for col in 0..<4 {
            for row in 0..<4 {
                array.append(transform[col][row])
            }
        }
        self.transformArray = array
    }
    
    /// Creates from anchor data
    public init(from data: ARAnchorData, metadata: [String: String] = [:]) {
        self.init(
            id: data.id,
            name: data.name ?? "Anchor",
            transform: data.transform,
            type: data.type,
            metadata: metadata
        )
    }
    
    /// Position extracted from transform
    public var position: SIMD3<Float> {
        SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}

// MARK: - Persistent Entity

/// An entity that can be persisted and restored.
public struct PersistentEntity: Codable, Identifiable, Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Entity name
    public let name: String
    
    /// Position
    public let position: [Float]
    
    /// Rotation as quaternion
    public let rotation: [Float]
    
    /// Scale
    public let scale: [Float]
    
    /// Associated anchor ID
    public let anchorID: UUID?
    
    /// Entity type identifier
    public let typeID: String
    
    /// Custom data
    public let userData: [String: String]
    
    /// Creation timestamp
    public let createdAt: Date
    
    /// Creates a persistent entity
    public init(
        id: UUID = UUID(),
        name: String,
        position: SIMD3<Float>,
        rotation: simd_quatf,
        scale: SIMD3<Float>,
        anchorID: UUID? = nil,
        typeID: String = "generic",
        userData: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.position = [position.x, position.y, position.z]
        self.rotation = [rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w]
        self.scale = [scale.x, scale.y, scale.z]
        self.anchorID = anchorID
        self.typeID = typeID
        self.userData = userData
        self.createdAt = Date()
    }
    
    /// Creates from entity
    public init(from entity: ARCraftEntity, anchorID: UUID? = nil, typeID: String = "generic") {
        self.init(
            id: entity.id,
            name: entity.name,
            position: entity.transform.position,
            rotation: entity.transform.rotation,
            scale: entity.transform.scale,
            anchorID: anchorID,
            typeID: typeID
        )
    }
    
    /// Gets position as SIMD3
    public var simdPosition: SIMD3<Float> {
        SIMD3<Float>(position[0], position[1], position[2])
    }
    
    /// Gets rotation as quaternion
    public var simdRotation: simd_quatf {
        simd_quatf(ix: rotation[0], iy: rotation[1], iz: rotation[2], r: rotation[3])
    }
    
    /// Gets scale as SIMD3
    public var simdScale: SIMD3<Float> {
        SIMD3<Float>(scale[0], scale[1], scale[2])
    }
}

// MARK: - World Map Data

/// Serializable world map data.
public struct WorldMapData: Codable, Sendable {
    /// Version for compatibility
    public let version: Int
    
    /// Map identifier
    public let id: UUID
    
    /// Human-readable name
    public var name: String
    
    /// Creation timestamp
    public let createdAt: Date
    
    /// Last modified timestamp
    public var modifiedAt: Date
    
    /// Persisted anchors
    public var anchors: [PersistentAnchor]
    
    /// Persisted entities
    public var entities: [PersistentEntity]
    
    /// Custom metadata
    public var metadata: [String: String]
    
    /// Center point of mapped area
    public var centerPoint: [Float]?
    
    /// Extent of mapped area
    public var extent: [Float]?
    
    /// Current version
    public static let currentVersion = 1
    
    /// Creates world map data
    public init(
        name: String = "World Map",
        anchors: [PersistentAnchor] = [],
        entities: [PersistentEntity] = [],
        metadata: [String: String] = [:]
    ) {
        self.version = Self.currentVersion
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.anchors = anchors
        self.entities = entities
        self.metadata = metadata
    }
    
    /// Adds an anchor
    public mutating func addAnchor(_ anchor: PersistentAnchor) {
        anchors.append(anchor)
        modifiedAt = Date()
    }
    
    /// Adds an entity
    public mutating func addEntity(_ entity: PersistentEntity) {
        entities.append(entity)
        modifiedAt = Date()
    }
    
    /// Removes an anchor by ID
    public mutating func removeAnchor(id: UUID) {
        anchors.removeAll { $0.id == id }
        modifiedAt = Date()
    }
    
    /// Removes an entity by ID
    public mutating func removeEntity(id: UUID) {
        entities.removeAll { $0.id == id }
        modifiedAt = Date()
    }
}

// MARK: - World Map Manager

/// Manages world map persistence.
///
/// `WorldMapManager` handles saving and loading AR world maps
/// for persistent AR experiences.
///
/// ## Example
///
/// ```swift
/// let manager = WorldMapManager()
///
/// // Save current session
/// try await manager.save(name: "LivingRoom")
///
/// // Load and restore
/// if let map = try await manager.load(name: "LivingRoom") {
///     restoreExperience(from: map)
/// }
/// ```
public final class WorldMapManager: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Current map state
    public private(set) var mapState: WorldMapState = .notAvailable
    
    /// Currently loaded map data
    public private(set) var currentMap: WorldMapData?
    
    /// Storage directory URL
    public let storageDirectory: URL
    
    /// File extension for saved maps
    public let fileExtension = "armap"
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    /// Creates a world map manager
    public init(directory: URL? = nil) {
        if let directory = directory {
            self.storageDirectory = directory
        } else {
            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.storageDirectory = documents.appendingPathComponent("ARMaps", isDirectory: true)
        }
        
        createDirectoryIfNeeded()
    }
    
    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: storageDirectory.path) {
            try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Saving
    
    /// Saves current map data.
    public func save(map: WorldMapData) throws {
        let url = fileURL(for: map.name)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(map)
        try data.write(to: url)
        currentMap = map
    }
    
    /// Saves with a specific name.
    public func save(
        name: String,
        anchors: [PersistentAnchor],
        entities: [PersistentEntity],
        metadata: [String: String] = [:]
    ) throws {
        var map = WorldMapData(name: name, anchors: anchors, entities: entities, metadata: metadata)
        try save(map: map)
    }
    
    /// Creates map data from current session.
    public func createMapData(
        from session: ARCraftSession,
        coordinator: ARCoordinator,
        name: String
    ) -> WorldMapData {
        let anchors = session.anchors.map { PersistentAnchor(from: $0) }
        let entities = coordinator.sceneGraph.allEntities.map { PersistentEntity(from: $0) }
        return WorldMapData(name: name, anchors: anchors, entities: entities)
    }
    
    // MARK: - Loading
    
    /// Loads a map by name.
    public func load(name: String) throws -> WorldMapData? {
        let url = fileURL(for: name)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        
        let data = try Data(contentsOf: url)
        let map = try decoder.decode(WorldMapData.self, from: data)
        currentMap = map
        return map
    }
    
    /// Loads a map from URL.
    public func load(url: URL) throws -> WorldMapData {
        let data = try Data(contentsOf: url)
        let map = try decoder.decode(WorldMapData.self, from: data)
        currentMap = map
        return map
    }
    
    /// Lists all saved maps.
    public func listSavedMaps() throws -> [String] {
        let files = try fileManager.contentsOfDirectory(atPath: storageDirectory.path)
        return files
            .filter { $0.hasSuffix(".\(fileExtension)") }
            .map { String($0.dropLast(fileExtension.count + 1)) }
    }
    
    /// Gets metadata for all saved maps.
    public func listSavedMapsWithMetadata() throws -> [MapInfo] {
        let names = try listSavedMaps()
        return names.compactMap { name -> MapInfo? in
            guard let map = try? load(name: name) else { return nil }
            return MapInfo(
                name: map.name,
                id: map.id,
                createdAt: map.createdAt,
                modifiedAt: map.modifiedAt,
                anchorCount: map.anchors.count,
                entityCount: map.entities.count
            )
        }
    }
    
    // MARK: - Deletion
    
    /// Deletes a saved map.
    public func delete(name: String) throws {
        let url = fileURL(for: name)
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
        
        if currentMap?.name == name {
            currentMap = nil
        }
    }
    
    /// Deletes all saved maps.
    public func deleteAll() throws {
        let maps = try listSavedMaps()
        for name in maps {
            try delete(name: name)
        }
        currentMap = nil
    }
    
    // MARK: - Utility
    
    private func fileURL(for name: String) -> URL {
        storageDirectory.appendingPathComponent("\(name).\(fileExtension)")
    }
    
    /// Checks if a map exists.
    public func exists(name: String) -> Bool {
        fileManager.fileExists(atPath: fileURL(for: name).path)
    }
    
    /// Gets file size for a map.
    public func fileSize(for name: String) -> Int? {
        let url = fileURL(for: name)
        guard let attrs = try? fileManager.attributesOfItem(atPath: url.path) else { return nil }
        return attrs[.size] as? Int
    }
    
    /// Exports map to a shareable format.
    public func export(name: String) throws -> Data {
        let url = fileURL(for: name)
        return try Data(contentsOf: url)
    }
    
    /// Imports map from data.
    public func importMap(data: Data, name: String? = nil) throws {
        let map = try decoder.decode(WorldMapData.self, from: data)
        var importedMap = map
        if let name = name {
            importedMap.name = name
        }
        try save(map: importedMap)
    }
}

// MARK: - Map Info

/// Summary information about a saved map.
public struct MapInfo: Sendable {
    public let name: String
    public let id: UUID
    public let createdAt: Date
    public let modifiedAt: Date
    public let anchorCount: Int
    public let entityCount: Int
}

// MARK: - Relocation Result

/// Result of attempting to relocalize in a saved map.
public struct RelocationResult: Sendable {
    /// Whether relocation was successful
    public let success: Bool
    
    /// Confidence of the relocation (0-1)
    public let confidence: Float
    
    /// Transform from old map to new session
    public let transform: simd_float4x4?
    
    /// Number of matched features
    public let matchedFeatures: Int
    
    /// Error if relocation failed
    public let error: Error?
}
