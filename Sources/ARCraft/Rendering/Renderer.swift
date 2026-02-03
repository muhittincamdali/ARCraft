//
//  Renderer.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

#if canImport(Metal)
import Metal
import MetalKit
#endif

// MARK: - Render Quality

/// Quality level for rendering.
public enum RenderQuality: String, Sendable, CaseIterable {
    /// Low quality - best performance
    case low
    
    /// Medium quality - balanced
    case medium
    
    /// High quality - best visuals
    case high
    
    /// Ultra quality - maximum fidelity
    case ultra
    
    /// Description
    public var description: String {
        rawValue.capitalized
    }
    
    /// Recommended MSAA sample count
    public var msaaSamples: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 4
        case .ultra: return 8
        }
    }
    
    /// Shadow map resolution
    public var shadowMapSize: Int {
        switch self {
        case .low: return 512
        case .medium: return 1024
        case .high: return 2048
        case .ultra: return 4096
        }
    }
}

// MARK: - Render Pass

/// Types of render passes.
public enum RenderPass: String, Sendable, CaseIterable {
    /// Shadow depth pass
    case shadowDepth
    
    /// G-Buffer pass for deferred rendering
    case gBuffer
    
    /// Opaque geometry pass
    case opaque
    
    /// Transparent geometry pass
    case transparent
    
    /// Post-processing pass
    case postProcess
    
    /// UI overlay pass
    case ui
}

// MARK: - Render Statistics

/// Statistics from rendering.
public struct RenderStatistics: Sendable {
    /// Number of draw calls
    public var drawCalls: Int
    
    /// Number of triangles rendered
    public var triangleCount: Int
    
    /// Number of visible entities
    public var visibleEntities: Int
    
    /// Number of lights
    public var lightCount: Int
    
    /// Number of shadow-casting lights
    public var shadowCasterCount: Int
    
    /// Frame render time in milliseconds
    public var frameTimeMs: Double
    
    /// GPU memory used in bytes
    public var gpuMemoryUsed: Int
    
    /// Creates statistics
    public init() {
        self.drawCalls = 0
        self.triangleCount = 0
        self.visibleEntities = 0
        self.lightCount = 0
        self.shadowCasterCount = 0
        self.frameTimeMs = 0
        self.gpuMemoryUsed = 0
    }
}

// MARK: - Render Options

/// Options for controlling rendering behavior.
public struct RenderOptions: Sendable {
    /// Render quality level
    public var quality: RenderQuality
    
    /// Whether shadows are enabled
    public var shadowsEnabled: Bool
    
    /// Whether bloom is enabled
    public var bloomEnabled: Bool
    
    /// Bloom intensity
    public var bloomIntensity: Float
    
    /// Whether ambient occlusion is enabled
    public var aoEnabled: Bool
    
    /// AO intensity
    public var aoIntensity: Float
    
    /// Whether anti-aliasing is enabled
    public var antiAliasingEnabled: Bool
    
    /// Whether depth of field is enabled
    public var dofEnabled: Bool
    
    /// Focus distance for DoF
    public var focusDistance: Float
    
    /// Aperture for DoF
    public var aperture: Float
    
    /// Whether motion blur is enabled
    public var motionBlurEnabled: Bool
    
    /// Motion blur strength
    public var motionBlurStrength: Float
    
    /// Exposure value
    public var exposure: Float
    
    /// Tone mapping operator
    public var toneMapping: ToneMapping
    
    /// Whether wireframe mode is enabled
    public var wireframeMode: Bool
    
    /// Whether to show bounding boxes
    public var showBoundingBoxes: Bool
    
    /// Tone mapping operators
    public enum ToneMapping: String, Sendable, CaseIterable {
        case linear
        case reinhard
        case aces
        case filmic
    }
    
    /// Creates default options
    public init() {
        self.quality = .high
        self.shadowsEnabled = true
        self.bloomEnabled = true
        self.bloomIntensity = 0.5
        self.aoEnabled = true
        self.aoIntensity = 0.5
        self.antiAliasingEnabled = true
        self.dofEnabled = false
        self.focusDistance = 2.0
        self.aperture = 0.05
        self.motionBlurEnabled = false
        self.motionBlurStrength = 0.5
        self.exposure = 1.0
        self.toneMapping = .aces
        self.wireframeMode = false
        self.showBoundingBoxes = false
    }
    
    /// Performance-focused options
    public static var performance: RenderOptions {
        var options = RenderOptions()
        options.quality = .low
        options.shadowsEnabled = false
        options.bloomEnabled = false
        options.aoEnabled = false
        options.antiAliasingEnabled = false
        return options
    }
    
    /// Quality-focused options
    public static var quality: RenderOptions {
        var options = RenderOptions()
        options.quality = .ultra
        options.shadowsEnabled = true
        options.bloomEnabled = true
        options.aoEnabled = true
        options.antiAliasingEnabled = true
        return options
    }
}

// MARK: - Camera

/// Camera for rendering.
public struct RenderCamera: Sendable {
    /// World transform
    public var transform: simd_float4x4
    
    /// View matrix
    public var viewMatrix: simd_float4x4
    
    /// Projection matrix
    public var projectionMatrix: simd_float4x4
    
    /// Field of view in radians
    public var fieldOfView: Float
    
    /// Near clip plane
    public var nearPlane: Float
    
    /// Far clip plane
    public var farPlane: Float
    
    /// Aspect ratio
    public var aspectRatio: Float
    
    /// Creates a camera
    public init(
        transform: simd_float4x4 = matrix_identity_float4x4,
        fieldOfView: Float = .pi / 3,
        aspectRatio: Float = 16.0 / 9.0,
        nearPlane: Float = 0.01,
        farPlane: Float = 1000
    ) {
        self.transform = transform
        self.viewMatrix = transform.inverse
        self.fieldOfView = fieldOfView
        self.aspectRatio = aspectRatio
        self.nearPlane = nearPlane
        self.farPlane = farPlane
        self.projectionMatrix = Self.perspectiveProjection(
            fov: fieldOfView,
            aspect: aspectRatio,
            near: nearPlane,
            far: farPlane
        )
    }
    
    /// Position in world space
    public var position: SIMD3<Float> {
        SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    /// Forward direction
    public var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-transform.columns.2.x, -transform.columns.2.y, -transform.columns.2.z))
    }
    
    /// Updates view matrix from transform
    public mutating func updateViewMatrix() {
        viewMatrix = transform.inverse
    }
    
    /// Creates perspective projection matrix
    public static func perspectiveProjection(
        fov: Float,
        aspect: Float,
        near: Float,
        far: Float
    ) -> simd_float4x4 {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = far / (near - far)
        
        return simd_float4x4(
            SIMD4<Float>(x, 0, 0, 0),
            SIMD4<Float>(0, y, 0, 0),
            SIMD4<Float>(0, 0, z, -1),
            SIMD4<Float>(0, 0, z * near, 0)
        )
    }
}

// MARK: - Render Queue

/// Queue for organizing render commands.
public final class RenderQueue: @unchecked Sendable {
    
    /// Queued draw commands
    private var commands: [DrawCommand] = []
    
    /// Creates a render queue
    public init() {}
    
    /// Adds a draw command
    public func enqueue(_ command: DrawCommand) {
        commands.append(command)
    }
    
    /// Sorts commands for optimal rendering
    public func sort() {
        commands.sort { a, b in
            // Sort by pass, then by material, then by depth
            if a.pass != b.pass {
                return a.pass.rawValue < b.pass.rawValue
            }
            if a.materialID != b.materialID {
                return a.materialID.uuidString < b.materialID.uuidString
            }
            return a.depth < b.depth
        }
    }
    
    /// Gets commands for a specific pass
    public func commands(for pass: RenderPass) -> [DrawCommand] {
        commands.filter { $0.pass == pass }
    }
    
    /// All commands
    public var allCommands: [DrawCommand] {
        commands
    }
    
    /// Clears the queue
    public func clear() {
        commands.removeAll()
    }
    
    /// Number of commands
    public var count: Int {
        commands.count
    }
}

// MARK: - Draw Command

/// A single draw command.
public struct DrawCommand: Sendable {
    /// Entity to draw
    public let entityID: UUID
    
    /// Render pass
    public let pass: RenderPass
    
    /// Material ID
    public let materialID: UUID
    
    /// World transform
    public let transform: simd_float4x4
    
    /// Depth for sorting
    public let depth: Float
    
    /// Creates a draw command
    public init(
        entityID: UUID,
        pass: RenderPass,
        materialID: UUID,
        transform: simd_float4x4,
        depth: Float
    ) {
        self.entityID = entityID
        self.pass = pass
        self.materialID = materialID
        self.transform = transform
        self.depth = depth
    }
}

// MARK: - Renderer

/// Main renderer for AR content.
///
/// `Renderer` handles the rendering pipeline for AR experiences,
/// including culling, sorting, and drawing of entities.
///
/// ## Example
///
/// ```swift
/// let renderer = Renderer()
/// renderer.options.quality = .high
/// renderer.options.shadowsEnabled = true
///
/// // In render loop
/// renderer.beginFrame()
/// renderer.submit(entities)
/// renderer.render(camera: camera)
/// renderer.endFrame()
/// ```
public final class Renderer: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Render options
    public var options: RenderOptions
    
    /// Current statistics
    public private(set) var statistics: RenderStatistics
    
    /// Render queue
    private let queue: RenderQueue
    
    /// Viewport size
    public var viewportSize: SIMD2<Float>
    
    /// Whether the renderer is initialized
    public private(set) var isInitialized: Bool = false
    
    /// Background color
    public var backgroundColor: SIMD4<Float>
    
    /// Ambient light color
    public var ambientLight: SIMD3<Float>
    
    /// Frame counter
    private var frameCount: UInt64 = 0
    
    /// Last frame time
    private var lastFrameTime: TimeInterval = 0
    
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a renderer
    public init(options: RenderOptions = RenderOptions()) {
        self.options = options
        self.statistics = RenderStatistics()
        self.queue = RenderQueue()
        self.viewportSize = SIMD2<Float>(1920, 1080)
        self.backgroundColor = SIMD4<Float>(0, 0, 0, 1)
        self.ambientLight = SIMD3<Float>(0.1, 0.1, 0.1)
    }
    
    /// Initializes the renderer
    public func initialize() async throws {
        // Initialize GPU resources
        isInitialized = true
    }
    
    // MARK: - Frame Lifecycle
    
    /// Begins a new frame
    public func beginFrame() {
        lock.lock()
        queue.clear()
        statistics = RenderStatistics()
        lastFrameTime = ProcessInfo.processInfo.systemUptime
        lock.unlock()
    }
    
    /// Ends the current frame
    public func endFrame() {
        lock.lock()
        frameCount += 1
        let elapsed = ProcessInfo.processInfo.systemUptime - lastFrameTime
        statistics.frameTimeMs = elapsed * 1000
        lock.unlock()
    }
    
    // MARK: - Submission
    
    /// Submits entities for rendering
    public func submit(_ entities: [ARCraftEntity], camera: RenderCamera) {
        lock.lock()
        defer { lock.unlock() }
        
        for entity in entities {
            guard entity.isEnabled && entity.isVisible else { continue }
            
            // Frustum culling (simplified)
            let worldPos = entity.worldPosition
            let toEntity = worldPos - camera.position
            let distanceAlongForward = dot(toEntity, camera.forward)
            
            if distanceAlongForward < camera.nearPlane || distanceAlongForward > camera.farPlane {
                continue
            }
            
            // Determine pass based on material
            let pass: RenderPass = .opaque // Default to opaque
            
            let command = DrawCommand(
                entityID: entity.id,
                pass: pass,
                materialID: UUID(), // Would use actual material ID
                transform: entity.worldTransform.matrix,
                depth: distanceAlongForward
            )
            
            queue.enqueue(command)
            statistics.visibleEntities += 1
        }
    }
    
    /// Submits a single entity
    public func submit(_ entity: ARCraftEntity, camera: RenderCamera) {
        submit([entity], camera: camera)
    }
    
    // MARK: - Rendering
    
    /// Renders the frame
    public func render(camera: RenderCamera) {
        lock.lock()
        queue.sort()
        let commands = queue.allCommands
        lock.unlock()
        
        // Shadow pass
        if options.shadowsEnabled {
            renderPass(.shadowDepth, commands: commands.filter { $0.pass == .shadowDepth }, camera: camera)
        }
        
        // Opaque pass
        renderPass(.opaque, commands: commands.filter { $0.pass == .opaque }, camera: camera)
        
        // Transparent pass
        renderPass(.transparent, commands: commands.filter { $0.pass == .transparent }, camera: camera)
        
        // Post-processing
        if options.bloomEnabled || options.aoEnabled || options.dofEnabled {
            renderPostProcess(camera: camera)
        }
    }
    
    private func renderPass(_ pass: RenderPass, commands: [DrawCommand], camera: RenderCamera) {
        for command in commands {
            renderCommand(command, camera: camera)
        }
    }
    
    private func renderCommand(_ command: DrawCommand, camera: RenderCamera) {
        statistics.drawCalls += 1
        statistics.triangleCount += 100 // Placeholder
    }
    
    private func renderPostProcess(camera: RenderCamera) {
        // Apply post-processing effects
        if options.aoEnabled {
            applyAmbientOcclusion()
        }
        
        if options.bloomEnabled {
            applyBloom()
        }
        
        if options.dofEnabled {
            applyDepthOfField()
        }
        
        if options.motionBlurEnabled {
            applyMotionBlur()
        }
        
        applyToneMapping()
    }
    
    private func applyAmbientOcclusion() {
        // SSAO implementation
    }
    
    private func applyBloom() {
        // Bloom implementation
    }
    
    private func applyDepthOfField() {
        // DoF implementation
    }
    
    private func applyMotionBlur() {
        // Motion blur implementation
    }
    
    private func applyToneMapping() {
        // Tone mapping implementation
    }
    
    // MARK: - Utility
    
    /// Resizes the viewport
    public func resize(to size: SIMD2<Float>) {
        viewportSize = size
    }
    
    /// Gets current frame count
    public var currentFrame: UInt64 {
        frameCount
    }
    
    /// Resets statistics
    public func resetStatistics() {
        lock.lock()
        statistics = RenderStatistics()
        lock.unlock()
    }
}

// MARK: - Debug Renderer

/// Debug rendering utilities.
public final class DebugRenderer: @unchecked Sendable {
    
    /// Queued debug lines
    private var lines: [(SIMD3<Float>, SIMD3<Float>, SIMD4<Float>)] = []
    
    /// Queued debug points
    private var points: [(SIMD3<Float>, Float, SIMD4<Float>)] = []
    
    /// Creates a debug renderer
    public init() {}
    
    /// Draws a line
    public func drawLine(from: SIMD3<Float>, to: SIMD3<Float>, color: SIMD4<Float> = SIMD4(1, 1, 1, 1)) {
        lines.append((from, to, color))
    }
    
    /// Draws a point
    public func drawPoint(_ position: SIMD3<Float>, size: Float = 0.01, color: SIMD4<Float> = SIMD4(1, 1, 1, 1)) {
        points.append((position, size, color))
    }
    
    /// Draws a bounding box
    public func drawBox(_ bounds: BoundingBox, color: SIMD4<Float> = SIMD4(0, 1, 0, 1)) {
        let min = bounds.min
        let max = bounds.max
        
        // Bottom face
        drawLine(from: SIMD3(min.x, min.y, min.z), to: SIMD3(max.x, min.y, min.z), color: color)
        drawLine(from: SIMD3(max.x, min.y, min.z), to: SIMD3(max.x, min.y, max.z), color: color)
        drawLine(from: SIMD3(max.x, min.y, max.z), to: SIMD3(min.x, min.y, max.z), color: color)
        drawLine(from: SIMD3(min.x, min.y, max.z), to: SIMD3(min.x, min.y, min.z), color: color)
        
        // Top face
        drawLine(from: SIMD3(min.x, max.y, min.z), to: SIMD3(max.x, max.y, min.z), color: color)
        drawLine(from: SIMD3(max.x, max.y, min.z), to: SIMD3(max.x, max.y, max.z), color: color)
        drawLine(from: SIMD3(max.x, max.y, max.z), to: SIMD3(min.x, max.y, max.z), color: color)
        drawLine(from: SIMD3(min.x, max.y, max.z), to: SIMD3(min.x, max.y, min.z), color: color)
        
        // Vertical edges
        drawLine(from: SIMD3(min.x, min.y, min.z), to: SIMD3(min.x, max.y, min.z), color: color)
        drawLine(from: SIMD3(max.x, min.y, min.z), to: SIMD3(max.x, max.y, min.z), color: color)
        drawLine(from: SIMD3(max.x, min.y, max.z), to: SIMD3(max.x, max.y, max.z), color: color)
        drawLine(from: SIMD3(min.x, min.y, max.z), to: SIMD3(min.x, max.y, max.z), color: color)
    }
    
    /// Draws a sphere wireframe
    public func drawSphere(center: SIMD3<Float>, radius: Float, color: SIMD4<Float> = SIMD4(0, 1, 0, 1)) {
        let segments = 16
        for ring in 0..<3 {
            for i in 0..<segments {
                let angle1 = Float(i) / Float(segments) * .pi * 2
                let angle2 = Float(i + 1) / Float(segments) * .pi * 2
                
                var p1: SIMD3<Float>
                var p2: SIMD3<Float>
                
                switch ring {
                case 0: // XY plane
                    p1 = center + SIMD3(cos(angle1), sin(angle1), 0) * radius
                    p2 = center + SIMD3(cos(angle2), sin(angle2), 0) * radius
                case 1: // XZ plane
                    p1 = center + SIMD3(cos(angle1), 0, sin(angle1)) * radius
                    p2 = center + SIMD3(cos(angle2), 0, sin(angle2)) * radius
                default: // YZ plane
                    p1 = center + SIMD3(0, cos(angle1), sin(angle1)) * radius
                    p2 = center + SIMD3(0, cos(angle2), sin(angle2)) * radius
                }
                
                drawLine(from: p1, to: p2, color: color)
            }
        }
    }
    
    /// Clears all debug geometry
    public func clear() {
        lines.removeAll()
        points.removeAll()
    }
    
    /// Gets line count
    public var lineCount: Int { lines.count }
    
    /// Gets point count
    public var pointCount: Int { points.count }
}
