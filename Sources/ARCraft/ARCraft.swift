//
//  ARCraft.swift
//  ARCraft
//
//  A comprehensive AR framework for iOS and visionOS.
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation

/// ARCraft version information.
public enum ARCraftVersion {
    /// Current version string
    public static let version = "1.0.0"
    
    /// Build number
    public static let build = 1
    
    /// Full version string
    public static var fullVersion: String {
        "\(version) (\(build))"
    }
}

/// ARCraft library entry point.
///
/// ARCraft is a comprehensive AR framework for building immersive
/// augmented reality experiences on iOS and visionOS.
///
/// ## Features
///
/// - **Session Management**: Easy-to-use AR session lifecycle
/// - **Entity System**: Component-based entity architecture
/// - **Anchors**: Support for world, image, plane, and object anchors
/// - **Gestures**: Built-in gesture recognition and handling
/// - **Materials**: PBR material system with texture support
/// - **Physics**: Real-time physics simulation
/// - **Animations**: Flexible animation system with easing
/// - **Persistence**: Save and restore AR experiences
/// - **SwiftUI**: Native SwiftUI integration
///
/// ## Quick Start
///
/// ```swift
/// import ARCraft
/// import SwiftUI
///
/// struct ContentView: View {
///     @StateObject private var arView = ARCraftView()
///     
///     var body: some View {
///         ARCraftViewRepresentable(arView: arView)
///             .ignoresSafeArea()
///             .onAppear {
///                 Task {
///                     try await arView.start()
///                     addContent()
///                 }
///             }
///     }
///     
///     func addContent() {
///         let cube = ModelEntity.box(size: SIMD3<Float>(0.1, 0.1, 0.1))
///         cube.transform.position = SIMD3<Float>(0, 0, -0.5)
///         arView.addEntity(cube)
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Essentials
/// - ``ARCraftSession``
/// - ``ARCraftView``
/// - ``ARCoordinator``
///
/// ### Entities
/// - ``ARCraftEntity``
/// - ``ModelEntity``
/// - ``LightEntity``
///
/// ### Anchors
/// - ``AnchorManager``
/// - ``PlaneAnchor``
/// - ``ImageAnchor``
/// - ``ObjectAnchor``
///
/// ### Interaction
/// - ``GestureHandler``
/// - ``TapHandler``
/// - ``PanHandler``
///
/// ### Rendering
/// - ``Renderer``
/// - ``MaterialBuilder``
/// - ``PBRMaterial``
///
/// ### Physics
/// - ``PhysicsWorld``
/// - ``PhysicsBody``
/// - ``CollisionComponent``
///
/// ### Animation
/// - ``AnimationController``
/// - ``Animation``
/// - ``EasingFunction``
///
/// ### Persistence
/// - ``WorldMapManager``
/// - ``WorldMapData``
public enum ARCraft {
    
    /// Initializes the ARCraft framework.
    ///
    /// Call this method before using any ARCraft functionality
    /// to ensure proper initialization.
    public static func initialize() {
        // Framework initialization
        #if DEBUG
        print("[ARCraft] Initialized v\(ARCraftVersion.fullVersion)")
        #endif
    }
    
    /// Checks if AR is supported on the current device.
    ///
    /// - Returns: Whether AR capabilities are available
    public static var isSupported: Bool {
        #if os(iOS)
        return true
        #elseif os(visionOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Current platform identifier.
    public static var platform: String {
        #if os(iOS)
        return "iOS"
        #elseif os(visionOS)
        return "visionOS"
        #elseif os(macOS)
        return "macOS"
        #else
        return "Unknown"
        #endif
    }
    
    /// Supported tracking modes on current platform.
    public static var supportedTrackingModes: [ARTrackingMode] {
        #if os(iOS)
        return [.world, .image, .face, .body, .object]
        #elseif os(visionOS)
        return [.world, .hand]
        #else
        return []
        #endif
    }
}

// MARK: - Public API Re-exports

// Core
public typealias Session = ARCraftSession
public typealias Configuration = ARCraftConfiguration
public typealias Coordinator = ARCoordinator

// Entities
public typealias Entity = ARCraftEntity
public typealias Model = ModelEntity
public typealias Light = LightEntity

// Materials
public typealias Material = PBRMaterial
public typealias MaterialBuilder = ARCraft.MaterialBuilder

// Convenience type aliases for common SIMD types
public typealias Float2 = SIMD2<Float>
public typealias Float3 = SIMD3<Float>
public typealias Float4 = SIMD4<Float>
public typealias Float4x4 = simd_float4x4
public typealias Quaternion = simd_quatf
