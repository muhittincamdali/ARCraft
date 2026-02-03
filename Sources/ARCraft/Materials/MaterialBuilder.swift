//
//  MaterialBuilder.swift
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

// MARK: - Material Type

/// Types of materials available.
public enum MaterialType: String, Sendable, CaseIterable {
    /// Physically-based rendering material
    case pbr
    
    /// Simple unlit material
    case unlit
    
    /// Occlusion material (invisible but receives shadows)
    case occlusion
    
    /// Video material
    case video
    
    /// Portal material
    case portal
    
    /// Custom shader material
    case custom
    
    /// Description
    public var description: String {
        switch self {
        case .pbr: return "PBR"
        case .unlit: return "Unlit"
        case .occlusion: return "Occlusion"
        case .video: return "Video"
        case .portal: return "Portal"
        case .custom: return "Custom"
        }
    }
}

// MARK: - Color

/// RGBA color representation.
public struct Color4: Sendable, Equatable {
    public var red: Float
    public var green: Float
    public var blue: Float
    public var alpha: Float
    
    public init(red: Float, green: Float, blue: Float, alpha: Float = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init(r: Int, g: Int, b: Int, a: Int = 255) {
        self.red = Float(r) / 255
        self.green = Float(g) / 255
        self.blue = Float(b) / 255
        self.alpha = Float(a) / 255
    }
    
    public init(hex: UInt32, alpha: Float = 1) {
        self.red = Float((hex >> 16) & 0xFF) / 255
        self.green = Float((hex >> 8) & 0xFF) / 255
        self.blue = Float(hex & 0xFF) / 255
        self.alpha = alpha
    }
    
    public init(gray: Float, alpha: Float = 1) {
        self.red = gray
        self.green = gray
        self.blue = gray
        self.alpha = alpha
    }
    
    public static let white = Color4(red: 1, green: 1, blue: 1)
    public static let black = Color4(red: 0, green: 0, blue: 0)
    public static let red = Color4(red: 1, green: 0, blue: 0)
    public static let green = Color4(red: 0, green: 1, blue: 0)
    public static let blue = Color4(red: 0, green: 0, blue: 1)
    public static let yellow = Color4(red: 1, green: 1, blue: 0)
    public static let cyan = Color4(red: 0, green: 1, blue: 1)
    public static let magenta = Color4(red: 1, green: 0, blue: 1)
    public static let clear = Color4(red: 0, green: 0, blue: 0, alpha: 0)
    public static let gray = Color4(gray: 0.5)
    
    public var simd: SIMD4<Float> {
        SIMD4<Float>(red, green, blue, alpha)
    }
    
    public var rgb: SIMD3<Float> {
        SIMD3<Float>(red, green, blue)
    }
    
    public func withAlpha(_ alpha: Float) -> Color4 {
        Color4(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public var luminance: Float {
        0.299 * red + 0.587 * green + 0.114 * blue
    }
    
    public static func lerp(_ a: Color4, _ b: Color4, t: Float) -> Color4 {
        Color4(
            red: a.red + (b.red - a.red) * t,
            green: a.green + (b.green - a.green) * t,
            blue: a.blue + (b.blue - a.blue) * t,
            alpha: a.alpha + (b.alpha - a.alpha) * t
        )
    }
}

// MARK: - Texture Source

/// Source for texture data.
public enum TextureSource: Sendable, Equatable {
    /// Named resource
    case named(String)
    
    /// File path
    case file(String)
    
    /// URL
    case url(URL)
    
    /// Solid color
    case color(Color4)
    
    /// Procedural texture
    case procedural(String, [String: Float])
}

// MARK: - Texture Map

/// A texture map for material channels.
public struct TextureMap: Sendable, Equatable {
    /// Source of the texture
    public var source: TextureSource
    
    /// UV scale
    public var scale: SIMD2<Float>
    
    /// UV offset
    public var offset: SIMD2<Float>
    
    /// Rotation in radians
    public var rotation: Float
    
    /// Whether to use trilinear filtering
    public var trilinearFiltering: Bool
    
    /// Wrap mode
    public var wrapMode: WrapMode
    
    /// Wrap modes
    public enum WrapMode: String, Sendable {
        case `repeat`
        case clamp
        case mirror
    }
    
    /// Creates a texture map
    public init(
        source: TextureSource,
        scale: SIMD2<Float> = SIMD2(1, 1),
        offset: SIMD2<Float> = SIMD2(0, 0),
        rotation: Float = 0,
        trilinearFiltering: Bool = true,
        wrapMode: WrapMode = .repeat
    ) {
        self.source = source
        self.scale = scale
        self.offset = offset
        self.rotation = rotation
        self.trilinearFiltering = trilinearFiltering
        self.wrapMode = wrapMode
    }
    
    /// Creates from a named resource
    public static func named(_ name: String) -> TextureMap {
        TextureMap(source: .named(name))
    }
    
    /// Creates from a solid color
    public static func color(_ color: Color4) -> TextureMap {
        TextureMap(source: .color(color))
    }
}

// MARK: - Built Material

/// A fully configured material ready for use.
public struct BuiltMaterial: Sendable, Equatable {
    /// Unique identifier
    public let id: UUID
    
    /// Name of the material
    public var name: String
    
    /// Type of material
    public var type: MaterialType
    
    /// Base color
    public var baseColor: Color4
    
    /// Base color texture
    public var baseColorTexture: TextureMap?
    
    /// Roughness value (0-1)
    public var roughness: Float
    
    /// Roughness texture
    public var roughnessTexture: TextureMap?
    
    /// Metallic value (0-1)
    public var metallic: Float
    
    /// Metallic texture
    public var metallicTexture: TextureMap?
    
    /// Normal map texture
    public var normalTexture: TextureMap?
    
    /// Normal map scale
    public var normalScale: Float
    
    /// Emissive color
    public var emissiveColor: Color4
    
    /// Emissive texture
    public var emissiveTexture: TextureMap?
    
    /// Emissive intensity
    public var emissiveIntensity: Float
    
    /// Ambient occlusion texture
    public var aoTexture: TextureMap?
    
    /// AO intensity
    public var aoIntensity: Float
    
    /// Whether the material is double-sided
    public var isDoubleSided: Bool
    
    /// Blend mode
    public var blendMode: BlendMode
    
    /// Alpha cutoff for masked mode
    public var alphaCutoff: Float
    
    /// Blend modes
    public enum BlendMode: String, Sendable {
        case opaque
        case transparent
        case additive
        case masked
    }
    
    /// Creates a default material
    public init(name: String = "Material", type: MaterialType = .pbr) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.baseColor = .white
        self.roughness = 0.5
        self.metallic = 0
        self.normalScale = 1
        self.emissiveColor = .black
        self.emissiveIntensity = 0
        self.aoIntensity = 1
        self.isDoubleSided = false
        self.blendMode = .opaque
        self.alphaCutoff = 0.5
    }
}

// MARK: - Material Builder

/// Builder for creating materials with a fluent API.
///
/// `MaterialBuilder` provides a convenient way to configure materials
/// step by step using method chaining.
///
/// ## Example
///
/// ```swift
/// let material = MaterialBuilder("Gold")
///     .baseColor(.init(hex: 0xFFD700))
///     .metallic(1.0)
///     .roughness(0.3)
///     .build()
/// ```
public final class MaterialBuilder: @unchecked Sendable {
    
    private var material: BuiltMaterial
    
    // MARK: - Initialization
    
    /// Creates a new material builder.
    ///
    /// - Parameters:
    ///   - name: Name of the material
    ///   - type: Type of material
    public init(_ name: String = "Material", type: MaterialType = .pbr) {
        self.material = BuiltMaterial(name: name, type: type)
    }
    
    // MARK: - Base Color
    
    /// Sets the base color.
    @discardableResult
    public func baseColor(_ color: Color4) -> MaterialBuilder {
        material.baseColor = color
        return self
    }
    
    /// Sets the base color from RGB values.
    @discardableResult
    public func baseColor(r: Float, g: Float, b: Float, a: Float = 1) -> MaterialBuilder {
        material.baseColor = Color4(red: r, green: g, blue: b, alpha: a)
        return self
    }
    
    /// Sets the base color from hex.
    @discardableResult
    public func baseColor(hex: UInt32) -> MaterialBuilder {
        material.baseColor = Color4(hex: hex)
        return self
    }
    
    /// Sets the base color texture.
    @discardableResult
    public func baseColorTexture(_ texture: TextureMap) -> MaterialBuilder {
        material.baseColorTexture = texture
        return self
    }
    
    /// Sets the base color texture by name.
    @discardableResult
    public func baseColorTexture(named: String) -> MaterialBuilder {
        material.baseColorTexture = .named(named)
        return self
    }
    
    // MARK: - Roughness
    
    /// Sets the roughness value.
    @discardableResult
    public func roughness(_ value: Float) -> MaterialBuilder {
        material.roughness = max(0, min(1, value))
        return self
    }
    
    /// Sets the roughness texture.
    @discardableResult
    public func roughnessTexture(_ texture: TextureMap) -> MaterialBuilder {
        material.roughnessTexture = texture
        return self
    }
    
    // MARK: - Metallic
    
    /// Sets the metallic value.
    @discardableResult
    public func metallic(_ value: Float) -> MaterialBuilder {
        material.metallic = max(0, min(1, value))
        return self
    }
    
    /// Sets the metallic texture.
    @discardableResult
    public func metallicTexture(_ texture: TextureMap) -> MaterialBuilder {
        material.metallicTexture = texture
        return self
    }
    
    // MARK: - Normal Map
    
    /// Sets the normal map texture.
    @discardableResult
    public func normalTexture(_ texture: TextureMap) -> MaterialBuilder {
        material.normalTexture = texture
        return self
    }
    
    /// Sets the normal map by name.
    @discardableResult
    public func normalTexture(named: String) -> MaterialBuilder {
        material.normalTexture = .named(named)
        return self
    }
    
    /// Sets the normal map scale.
    @discardableResult
    public func normalScale(_ scale: Float) -> MaterialBuilder {
        material.normalScale = scale
        return self
    }
    
    // MARK: - Emissive
    
    /// Sets the emissive color.
    @discardableResult
    public func emissive(_ color: Color4, intensity: Float = 1) -> MaterialBuilder {
        material.emissiveColor = color
        material.emissiveIntensity = intensity
        return self
    }
    
    /// Sets the emissive texture.
    @discardableResult
    public func emissiveTexture(_ texture: TextureMap) -> MaterialBuilder {
        material.emissiveTexture = texture
        return self
    }
    
    // MARK: - Ambient Occlusion
    
    /// Sets the AO texture.
    @discardableResult
    public func aoTexture(_ texture: TextureMap) -> MaterialBuilder {
        material.aoTexture = texture
        return self
    }
    
    /// Sets the AO intensity.
    @discardableResult
    public func aoIntensity(_ intensity: Float) -> MaterialBuilder {
        material.aoIntensity = intensity
        return self
    }
    
    // MARK: - Rendering Options
    
    /// Sets double-sided rendering.
    @discardableResult
    public func doubleSided(_ value: Bool = true) -> MaterialBuilder {
        material.isDoubleSided = value
        return self
    }
    
    /// Sets the blend mode.
    @discardableResult
    public func blendMode(_ mode: BuiltMaterial.BlendMode) -> MaterialBuilder {
        material.blendMode = mode
        return self
    }
    
    /// Sets alpha cutoff for masked mode.
    @discardableResult
    public func alphaCutoff(_ value: Float) -> MaterialBuilder {
        material.alphaCutoff = value
        material.blendMode = .masked
        return self
    }
    
    // MARK: - Build
    
    /// Builds and returns the configured material.
    public func build() -> BuiltMaterial {
        material
    }
}

// MARK: - Material Presets

/// Pre-configured material presets.
public enum MaterialPresets {
    /// Shiny metal material
    public static func metal(color: Color4 = .gray) -> BuiltMaterial {
        MaterialBuilder("Metal")
            .baseColor(color)
            .metallic(1.0)
            .roughness(0.2)
            .build()
    }
    
    /// Matte plastic material
    public static func plastic(color: Color4 = .white) -> BuiltMaterial {
        MaterialBuilder("Plastic")
            .baseColor(color)
            .metallic(0)
            .roughness(0.8)
            .build()
    }
    
    /// Glass material
    public static func glass(tint: Color4 = .white) -> BuiltMaterial {
        MaterialBuilder("Glass")
            .baseColor(tint.withAlpha(0.2))
            .metallic(0)
            .roughness(0.05)
            .blendMode(.transparent)
            .build()
    }
    
    /// Wood material
    public static func wood() -> BuiltMaterial {
        MaterialBuilder("Wood")
            .baseColor(Color4(hex: 0x8B4513))
            .metallic(0)
            .roughness(0.7)
            .build()
    }
    
    /// Concrete material
    public static func concrete() -> BuiltMaterial {
        MaterialBuilder("Concrete")
            .baseColor(Color4(gray: 0.6))
            .metallic(0)
            .roughness(0.9)
            .build()
    }
    
    /// Gold material
    public static func gold() -> BuiltMaterial {
        MaterialBuilder("Gold")
            .baseColor(Color4(hex: 0xFFD700))
            .metallic(1.0)
            .roughness(0.3)
            .build()
    }
    
    /// Silver material
    public static func silver() -> BuiltMaterial {
        MaterialBuilder("Silver")
            .baseColor(Color4(hex: 0xC0C0C0))
            .metallic(1.0)
            .roughness(0.3)
            .build()
    }
    
    /// Glowing material
    public static func glowing(color: Color4, intensity: Float = 2) -> BuiltMaterial {
        MaterialBuilder("Glowing")
            .baseColor(color)
            .emissive(color, intensity: intensity)
            .build()
    }
}
