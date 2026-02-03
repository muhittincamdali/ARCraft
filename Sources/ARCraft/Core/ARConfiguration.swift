//
//  ARConfiguration.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Tracking Mode

/// Specifies the type of AR tracking to use.
///
/// Choose the tracking mode that best fits your AR experience requirements.
/// Different modes have different hardware and environmental requirements.
public enum ARTrackingMode: String, Sendable, CaseIterable {
    /// World tracking using visual-inertial odometry
    case world
    
    /// Image tracking for detecting reference images
    case image
    
    /// Face tracking for facial feature detection
    case face
    
    /// Body tracking for full body pose estimation
    case body
    
    /// Object tracking for 3D object detection
    case object
    
    /// Hand tracking for gesture recognition
    case hand
    
    /// Geo tracking for location-based AR
    case geo
    
    /// Human-readable description of the tracking mode
    public var description: String {
        switch self {
        case .world: return "World Tracking"
        case .image: return "Image Tracking"
        case .face: return "Face Tracking"
        case .body: return "Body Tracking"
        case .object: return "Object Tracking"
        case .hand: return "Hand Tracking"
        case .geo: return "Geo Tracking"
        }
    }
    
    /// Minimum iOS version required for this tracking mode
    public var minimumIOSVersion: Float {
        switch self {
        case .world: return 11.0
        case .image: return 11.3
        case .face: return 11.0
        case .body: return 13.0
        case .object: return 12.0
        case .hand: return 14.0
        case .geo: return 14.0
        }
    }
}

// MARK: - Plane Detection

/// Options for plane detection during world tracking.
public struct PlaneDetectionOptions: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Detect horizontal planes (floors, tables, etc.)
    public static let horizontal = PlaneDetectionOptions(rawValue: 1 << 0)
    
    /// Detect vertical planes (walls, doors, etc.)
    public static let vertical = PlaneDetectionOptions(rawValue: 1 << 1)
    
    /// Detect all plane orientations
    public static let all: PlaneDetectionOptions = [.horizontal, .vertical]
    
    /// Human-readable description
    public var description: String {
        var parts: [String] = []
        if contains(.horizontal) { parts.append("Horizontal") }
        if contains(.vertical) { parts.append("Vertical") }
        return parts.isEmpty ? "None" : parts.joined(separator: ", ")
    }
}

// MARK: - Environment Texturing

/// Options for environment texturing quality.
public enum EnvironmentTexturing: String, Sendable, CaseIterable {
    /// No environment texturing
    case none
    
    /// Manual environment texturing
    case manual
    
    /// Automatic environment texturing
    case automatic
    
    /// Human-readable description
    public var description: String {
        switch self {
        case .none: return "None"
        case .manual: return "Manual"
        case .automatic: return "Automatic"
        }
    }
}

// MARK: - Scene Reconstruction

/// Options for scene reconstruction features.
public struct SceneReconstructionOptions: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Reconstruct scene mesh geometry
    public static let mesh = SceneReconstructionOptions(rawValue: 1 << 0)
    
    /// Include classification data for mesh faces
    public static let meshWithClassification = SceneReconstructionOptions(rawValue: 1 << 1)
    
    /// Description of selected options
    public var description: String {
        var parts: [String] = []
        if contains(.mesh) { parts.append("Mesh") }
        if contains(.meshWithClassification) { parts.append("Mesh with Classification") }
        return parts.isEmpty ? "None" : parts.joined(separator: ", ")
    }
}

// MARK: - Frame Semantics

/// Options for semantic information in AR frames.
public struct FrameSemantics: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Body detection semantics
    public static let bodyDetection = FrameSemantics(rawValue: 1 << 0)
    
    /// Person segmentation semantics
    public static let personSegmentation = FrameSemantics(rawValue: 1 << 1)
    
    /// Person segmentation with depth
    public static let personSegmentationWithDepth = FrameSemantics(rawValue: 1 << 2)
    
    /// Scene depth information
    public static let sceneDepth = FrameSemantics(rawValue: 1 << 3)
    
    /// Smoothed scene depth
    public static let smoothedSceneDepth = FrameSemantics(rawValue: 1 << 4)
}

// MARK: - Video Format

/// Configuration for video capture format.
public struct ARVideoFormat: Sendable, Equatable {
    /// Resolution width in pixels
    public let width: Int
    
    /// Resolution height in pixels
    public let height: Int
    
    /// Frame rate in frames per second
    public let framesPerSecond: Int
    
    /// Whether HDR is supported
    public let supportsHDR: Bool
    
    /// Creates a new video format configuration
    public init(width: Int, height: Int, framesPerSecond: Int, supportsHDR: Bool = false) {
        self.width = width
        self.height = height
        self.framesPerSecond = framesPerSecond
        self.supportsHDR = supportsHDR
    }
    
    /// Standard 720p format at 30fps
    public static let hd720p30 = ARVideoFormat(width: 1280, height: 720, framesPerSecond: 30)
    
    /// Standard 1080p format at 30fps
    public static let hd1080p30 = ARVideoFormat(width: 1920, height: 1080, framesPerSecond: 30)
    
    /// Standard 1080p format at 60fps
    public static let hd1080p60 = ARVideoFormat(width: 1920, height: 1080, framesPerSecond: 60)
    
    /// 4K format at 30fps
    public static let uhd4K30 = ARVideoFormat(width: 3840, height: 2160, framesPerSecond: 30)
    
    /// Aspect ratio of the format
    public var aspectRatio: Float {
        Float(width) / Float(height)
    }
    
    /// Total pixel count
    public var pixelCount: Int {
        width * height
    }
}

// MARK: - Light Estimation Mode

/// Options for light estimation during AR sessions.
public enum LightEstimationMode: String, Sendable, CaseIterable {
    /// No light estimation
    case disabled
    
    /// Ambient light intensity only
    case ambientIntensity
    
    /// Ambient light with color temperature
    case ambientLightAndColorTemperature
    
    /// Full environmental lighting with spherical harmonics
    case environmentalHDR
    
    /// Description of the mode
    public var description: String {
        switch self {
        case .disabled: return "Disabled"
        case .ambientIntensity: return "Ambient Intensity"
        case .ambientLightAndColorTemperature: return "Ambient Light & Color Temperature"
        case .environmentalHDR: return "Environmental HDR"
        }
    }
}

// MARK: - World Alignment

/// Specifies how the AR world coordinate system is aligned.
public enum ARWorldAlignment: String, Sendable, CaseIterable {
    /// Gravity-aligned with arbitrary heading
    case gravity
    
    /// Gravity-aligned with compass heading
    case gravityAndHeading
    
    /// Device camera aligned
    case camera
    
    /// Description of the alignment
    public var description: String {
        switch self {
        case .gravity: return "Gravity"
        case .gravityAndHeading: return "Gravity and Heading"
        case .camera: return "Camera"
        }
    }
}

// MARK: - Configuration

/// Configuration options for AR sessions.
///
/// Use `ARCraftConfiguration` to customize the behavior of your AR session.
/// You can configure tracking mode, plane detection, environment texturing,
/// and many other options.
///
/// ## Example
///
/// ```swift
/// let config = ARCraftConfiguration()
/// config.trackingMode = .world
/// config.planeDetection = [.horizontal, .vertical]
/// config.environmentTexturing = .automatic
/// config.lightEstimation = .environmentalHDR
///
/// let session = ARCraftSession(configuration: config)
/// ```
public final class ARCraftConfiguration: @unchecked Sendable {
    
    // MARK: - Tracking
    
    /// Primary tracking mode for the session
    public var trackingMode: ARTrackingMode
    
    /// Plane detection options
    public var planeDetection: PlaneDetectionOptions
    
    /// World alignment setting
    public var worldAlignment: ARWorldAlignment
    
    // MARK: - Environment
    
    /// Environment texturing mode
    public var environmentTexturing: EnvironmentTexturing
    
    /// Light estimation mode
    public var lightEstimation: LightEstimationMode
    
    /// Scene reconstruction options
    public var sceneReconstruction: SceneReconstructionOptions
    
    // MARK: - Frame
    
    /// Frame semantic options
    public var frameSemantics: FrameSemantics
    
    /// Video format for capture
    public var videoFormat: ARVideoFormat?
    
    /// Target frame rate
    public var targetFrameRate: Int
    
    // MARK: - Features
    
    /// Whether to enable people occlusion
    public var peopleOcclusion: Bool
    
    /// Whether to enable object occlusion
    public var objectOcclusion: Bool
    
    /// Whether to enable motion capture
    public var motionCapture: Bool
    
    /// Whether collaborative sessions are enabled
    public var collaborationEnabled: Bool
    
    /// Maximum number of tracked images
    public var maximumTrackedImages: Int
    
    /// Whether automatic focus is enabled
    public var autoFocusEnabled: Bool
    
    /// Whether scene depth is provided
    public var providesSceneDepth: Bool
    
    // MARK: - Performance
    
    /// Whether to run with reduced processing
    public var reducedProcessing: Bool
    
    /// Whether to enable high-resolution frames
    public var highResolutionFrames: Bool
    
    /// Maximum mesh memory budget in bytes
    public var meshMemoryBudget: Int
    
    // MARK: - Reference Items
    
    /// Reference images for image tracking
    public var referenceImages: Set<ARReferenceImage>
    
    /// Reference objects for object tracking
    public var referenceObjects: Set<ARReferenceObject>
    
    // MARK: - Initialization
    
    /// Creates a configuration with default settings.
    public init() {
        self.trackingMode = .world
        self.planeDetection = [.horizontal]
        self.worldAlignment = .gravity
        self.environmentTexturing = .automatic
        self.lightEstimation = .ambientLightAndColorTemperature
        self.sceneReconstruction = []
        self.frameSemantics = []
        self.videoFormat = nil
        self.targetFrameRate = 60
        self.peopleOcclusion = false
        self.objectOcclusion = false
        self.motionCapture = false
        self.collaborationEnabled = false
        self.maximumTrackedImages = 4
        self.autoFocusEnabled = true
        self.providesSceneDepth = false
        self.reducedProcessing = false
        self.highResolutionFrames = false
        self.meshMemoryBudget = 64 * 1024 * 1024
        self.referenceImages = []
        self.referenceObjects = []
    }
    
    /// Default configuration for basic AR experiences
    public static var `default`: ARCraftConfiguration {
        ARCraftConfiguration()
    }
    
    /// Configuration optimized for performance
    public static var performance: ARCraftConfiguration {
        let config = ARCraftConfiguration()
        config.environmentTexturing = .none
        config.lightEstimation = .ambientIntensity
        config.planeDetection = []
        config.reducedProcessing = true
        return config
    }
    
    /// Configuration optimized for quality
    public static var quality: ARCraftConfiguration {
        let config = ARCraftConfiguration()
        config.environmentTexturing = .automatic
        config.lightEstimation = .environmentalHDR
        config.planeDetection = .all
        config.sceneReconstruction = [.mesh, .meshWithClassification]
        config.highResolutionFrames = true
        return config
    }
    
    /// Configuration for image tracking
    public static var imageTracking: ARCraftConfiguration {
        let config = ARCraftConfiguration()
        config.trackingMode = .image
        config.maximumTrackedImages = 4
        return config
    }
    
    /// Whether this configuration requires world tracking
    public var requiresWorldTracking: Bool {
        trackingMode == .world || trackingMode == .geo
    }
    
    /// Validates the configuration
    public func validate() -> [String] {
        var errors: [String] = []
        
        if targetFrameRate < 1 || targetFrameRate > 120 {
            errors.append("Target frame rate must be between 1 and 120")
        }
        
        if maximumTrackedImages < 0 || maximumTrackedImages > 100 {
            errors.append("Maximum tracked images must be between 0 and 100")
        }
        
        if trackingMode == .image && referenceImages.isEmpty {
            errors.append("Image tracking requires reference images")
        }
        
        if trackingMode == .object && referenceObjects.isEmpty {
            errors.append("Object tracking requires reference objects")
        }
        
        return errors
    }
    
    /// Creates a copy of this configuration
    public func copy() -> ARCraftConfiguration {
        let config = ARCraftConfiguration()
        config.trackingMode = trackingMode
        config.planeDetection = planeDetection
        config.worldAlignment = worldAlignment
        config.environmentTexturing = environmentTexturing
        config.lightEstimation = lightEstimation
        config.sceneReconstruction = sceneReconstruction
        config.frameSemantics = frameSemantics
        config.videoFormat = videoFormat
        config.targetFrameRate = targetFrameRate
        config.peopleOcclusion = peopleOcclusion
        config.objectOcclusion = objectOcclusion
        config.motionCapture = motionCapture
        config.collaborationEnabled = collaborationEnabled
        config.maximumTrackedImages = maximumTrackedImages
        config.autoFocusEnabled = autoFocusEnabled
        config.providesSceneDepth = providesSceneDepth
        config.reducedProcessing = reducedProcessing
        config.highResolutionFrames = highResolutionFrames
        config.meshMemoryBudget = meshMemoryBudget
        config.referenceImages = referenceImages
        config.referenceObjects = referenceObjects
        return config
    }
}

// MARK: - Reference Image

/// A reference image for image tracking.
public struct ARReferenceImage: Hashable, Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Name of the reference image
    public let name: String
    
    /// Physical width of the image in meters
    public let physicalWidth: Float
    
    /// Optional physical height (if different aspect ratio)
    public let physicalHeight: Float?
    
    /// Creates a new reference image
    public init(name: String, physicalWidth: Float, physicalHeight: Float? = nil) {
        self.id = UUID()
        self.name = name
        self.physicalWidth = physicalWidth
        self.physicalHeight = physicalHeight
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ARReferenceImage, rhs: ARReferenceImage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Reference Object

/// A reference object for 3D object tracking.
public struct ARReferenceObject: Hashable, Sendable {
    /// Unique identifier
    public let id: UUID
    
    /// Name of the reference object
    public let name: String
    
    /// Center point of the object's bounding box
    public let center: SIMD3<Float>
    
    /// Extent of the object's bounding box
    public let extent: SIMD3<Float>
    
    /// Creates a new reference object
    public init(name: String, center: SIMD3<Float>, extent: SIMD3<Float>) {
        self.id = UUID()
        self.name = name
        self.center = center
        self.extent = extent
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ARReferenceObject, rhs: ARReferenceObject) -> Bool {
        lhs.id == rhs.id
    }
}
