//
//  PBRMaterial.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - PBR Workflow

/// PBR workflow type.
public enum PBRWorkflow: String, Sendable, CaseIterable {
    /// Metallic-roughness workflow
    case metallicRoughness
    
    /// Specular-glossiness workflow
    case specularGlossiness
    
    /// Description
    public var description: String {
        switch self {
        case .metallicRoughness: return "Metallic-Roughness"
        case .specularGlossiness: return "Specular-Glossiness"
        }
    }
}

// MARK: - Clear Coat

/// Clear coat layer settings.
public struct ClearCoat: Sendable, Equatable {
    /// Clear coat intensity (0-1)
    public var intensity: Float
    
    /// Clear coat roughness
    public var roughness: Float
    
    /// Clear coat normal map
    public var normalTexture: TextureMap?
    
    /// Normal scale
    public var normalScale: Float
    
    /// Creates clear coat settings
    public init(
        intensity: Float = 0,
        roughness: Float = 0.03,
        normalTexture: TextureMap? = nil,
        normalScale: Float = 1
    ) {
        self.intensity = intensity
        self.roughness = roughness
        self.normalTexture = normalTexture
        self.normalScale = normalScale
    }
    
    /// Default clear coat (automotive style)
    public static var automotive: ClearCoat {
        ClearCoat(intensity: 1, roughness: 0.02)
    }
}

// MARK: - Sheen

/// Sheen layer for fabric-like materials.
public struct Sheen: Sendable, Equatable {
    /// Sheen color
    public var color: Color4
    
    /// Sheen roughness
    public var roughness: Float
    
    /// Creates sheen settings
    public init(color: Color4 = .white, roughness: Float = 0.5) {
        self.color = color
        self.roughness = roughness
    }
    
    /// Velvet-like sheen
    public static var velvet: Sheen {
        Sheen(color: Color4(gray: 0.04), roughness: 0.3)
    }
    
    /// Satin-like sheen
    public static var satin: Sheen {
        Sheen(color: Color4(gray: 0.03), roughness: 0.5)
    }
}

// MARK: - Subsurface

/// Subsurface scattering settings.
public struct SubsurfaceScattering: Sendable, Equatable {
    /// Subsurface color
    public var color: Color4
    
    /// Scattering radius
    public var radius: SIMD3<Float>
    
    /// Intensity (0-1)
    public var intensity: Float
    
    /// Creates subsurface settings
    public init(
        color: Color4 = .red,
        radius: SIMD3<Float> = SIMD3<Float>(1, 0.2, 0.1),
        intensity: Float = 0.5
    ) {
        self.color = color
        self.radius = radius
        self.intensity = intensity
    }
    
    /// Skin-like subsurface
    public static var skin: SubsurfaceScattering {
        SubsurfaceScattering(
            color: Color4(hex: 0xFF8866),
            radius: SIMD3<Float>(1, 0.35, 0.15),
            intensity: 0.5
        )
    }
    
    /// Wax-like subsurface
    public static var wax: SubsurfaceScattering {
        SubsurfaceScattering(
            color: Color4(hex: 0xFFE0B0),
            radius: SIMD3<Float>(0.5, 0.5, 0.5),
            intensity: 0.8
        )
    }
}

// MARK: - Anisotropy

/// Anisotropic reflection settings.
public struct Anisotropy: Sendable, Equatable {
    /// Anisotropy strength (-1 to 1)
    public var strength: Float
    
    /// Rotation in radians
    public var rotation: Float
    
    /// Direction texture
    public var directionTexture: TextureMap?
    
    /// Creates anisotropy settings
    public init(
        strength: Float = 0,
        rotation: Float = 0,
        directionTexture: TextureMap? = nil
    ) {
        self.strength = strength
        self.rotation = rotation
        self.directionTexture = directionTexture
    }
    
    /// Brushed metal style
    public static var brushedMetal: Anisotropy {
        Anisotropy(strength: 0.5, rotation: 0)
    }
    
    /// Hair-like anisotropy
    public static var hair: Anisotropy {
        Anisotropy(strength: 0.8, rotation: 0)
    }
}

// MARK: - PBR Material

/// Physically-based rendering material.
///
/// `PBRMaterial` provides comprehensive PBR material settings
/// including advanced features like clear coat, subsurface scattering,
/// and anisotropy.
///
/// ## Example
///
/// ```swift
/// let carPaint = PBRMaterial(name: "CarPaint")
/// carPaint.baseColor = Color4(hex: 0xCC0000)
/// carPaint.metallic = 0.8
/// carPaint.roughness = 0.4
/// carPaint.clearCoat = .automotive
/// ```
public final class PBRMaterial: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Unique identifier
    public let id: UUID
    
    /// Material name
    public var name: String
    
    /// PBR workflow
    public var workflow: PBRWorkflow
    
    // MARK: - Base Properties
    
    /// Base color / albedo
    public var baseColor: Color4
    
    /// Base color texture
    public var baseColorTexture: TextureMap?
    
    /// Metallic factor (0-1)
    public var metallic: Float
    
    /// Metallic texture
    public var metallicTexture: TextureMap?
    
    /// Roughness factor (0-1)
    public var roughness: Float
    
    /// Roughness texture
    public var roughnessTexture: TextureMap?
    
    /// Combined metallic-roughness texture
    public var metallicRoughnessTexture: TextureMap?
    
    // MARK: - Specular-Glossiness (Alternative Workflow)
    
    /// Specular color (for specular-glossiness workflow)
    public var specularColor: Color4?
    
    /// Specular texture
    public var specularTexture: TextureMap?
    
    /// Glossiness factor (for specular-glossiness workflow)
    public var glossiness: Float?
    
    /// Glossiness texture
    public var glossinessTexture: TextureMap?
    
    // MARK: - Normal Map
    
    /// Normal map texture
    public var normalTexture: TextureMap?
    
    /// Normal map scale
    public var normalScale: Float
    
    // MARK: - Emissive
    
    /// Emissive color
    public var emissiveColor: Color4
    
    /// Emissive texture
    public var emissiveTexture: TextureMap?
    
    /// Emissive intensity multiplier
    public var emissiveIntensity: Float
    
    // MARK: - Occlusion
    
    /// Ambient occlusion texture
    public var occlusionTexture: TextureMap?
    
    /// Occlusion strength
    public var occlusionStrength: Float
    
    // MARK: - Advanced Properties
    
    /// Clear coat settings
    public var clearCoat: ClearCoat?
    
    /// Sheen settings
    public var sheen: Sheen?
    
    /// Subsurface scattering settings
    public var subsurface: SubsurfaceScattering?
    
    /// Anisotropy settings
    public var anisotropy: Anisotropy?
    
    /// Index of refraction
    public var ior: Float
    
    /// Transmission (for glass-like materials)
    public var transmission: Float
    
    /// Transmission texture
    public var transmissionTexture: TextureMap?
    
    /// Volume thickness for transmission
    public var thickness: Float
    
    /// Attenuation color for volume
    public var attenuationColor: Color4
    
    /// Attenuation distance
    public var attenuationDistance: Float
    
    // MARK: - Rendering Options
    
    /// Whether material is double-sided
    public var isDoubleSided: Bool
    
    /// Alpha mode
    public var alphaMode: AlphaMode
    
    /// Alpha cutoff for mask mode
    public var alphaCutoff: Float
    
    /// Whether to receive shadows
    public var receivesShadow: Bool
    
    /// Whether to cast shadows
    public var castsShadow: Bool
    
    /// Alpha modes
    public enum AlphaMode: String, Sendable {
        case opaque
        case blend
        case mask
    }
    
    // MARK: - Initialization
    
    /// Creates a new PBR material.
    public init(name: String = "PBRMaterial") {
        self.id = UUID()
        self.name = name
        self.workflow = .metallicRoughness
        
        // Base properties
        self.baseColor = .white
        self.metallic = 0
        self.roughness = 0.5
        
        // Normal
        self.normalScale = 1
        
        // Emissive
        self.emissiveColor = .black
        self.emissiveIntensity = 1
        
        // Occlusion
        self.occlusionStrength = 1
        
        // Advanced
        self.ior = 1.5
        self.transmission = 0
        self.thickness = 0
        self.attenuationColor = .white
        self.attenuationDistance = Float.infinity
        
        // Rendering
        self.isDoubleSided = false
        self.alphaMode = .opaque
        self.alphaCutoff = 0.5
        self.receivesShadow = true
        self.castsShadow = true
    }
    
    // MARK: - Factory Methods
    
    /// Creates a standard opaque material.
    public static func standard(
        color: Color4 = .white,
        roughness: Float = 0.5,
        metallic: Float = 0
    ) -> PBRMaterial {
        let material = PBRMaterial(name: "Standard")
        material.baseColor = color
        material.roughness = roughness
        material.metallic = metallic
        return material
    }
    
    /// Creates a metal material.
    public static func metal(
        color: Color4 = .gray,
        roughness: Float = 0.3
    ) -> PBRMaterial {
        let material = PBRMaterial(name: "Metal")
        material.baseColor = color
        material.roughness = roughness
        material.metallic = 1
        return material
    }
    
    /// Creates a glass material.
    public static func glass(
        color: Color4 = .white,
        roughness: Float = 0,
        ior: Float = 1.5
    ) -> PBRMaterial {
        let material = PBRMaterial(name: "Glass")
        material.baseColor = color.withAlpha(0)
        material.roughness = roughness
        material.metallic = 0
        material.transmission = 1
        material.ior = ior
        material.alphaMode = .blend
        return material
    }
    
    /// Creates an emissive material.
    public static func emissive(
        color: Color4,
        intensity: Float = 2
    ) -> PBRMaterial {
        let material = PBRMaterial(name: "Emissive")
        material.baseColor = color
        material.emissiveColor = color
        material.emissiveIntensity = intensity
        return material
    }
    
    /// Creates a car paint material.
    public static func carPaint(
        color: Color4,
        flakeIntensity: Float = 0.3
    ) -> PBRMaterial {
        let material = PBRMaterial(name: "CarPaint")
        material.baseColor = color
        material.metallic = 0.8
        material.roughness = 0.4
        material.clearCoat = .automotive
        return material
    }
    
    /// Creates a fabric material.
    public static func fabric(
        color: Color4,
        roughness: Float = 0.8
    ) -> PBRMaterial {
        let material = PBRMaterial(name: "Fabric")
        material.baseColor = color
        material.roughness = roughness
        material.metallic = 0
        material.sheen = .velvet
        material.isDoubleSided = true
        return material
    }
    
    /// Creates a skin material.
    public static func skin(
        color: Color4 = Color4(hex: 0xFFDBCA)
    ) -> PBRMaterial {
        let material = PBRMaterial(name: "Skin")
        material.baseColor = color
        material.roughness = 0.5
        material.metallic = 0
        material.subsurface = .skin
        return material
    }
    
    // MARK: - Utility
    
    /// Creates a copy of this material.
    public func copy() -> PBRMaterial {
        let copy = PBRMaterial(name: name + "_copy")
        copy.workflow = workflow
        copy.baseColor = baseColor
        copy.baseColorTexture = baseColorTexture
        copy.metallic = metallic
        copy.metallicTexture = metallicTexture
        copy.roughness = roughness
        copy.roughnessTexture = roughnessTexture
        copy.metallicRoughnessTexture = metallicRoughnessTexture
        copy.normalTexture = normalTexture
        copy.normalScale = normalScale
        copy.emissiveColor = emissiveColor
        copy.emissiveTexture = emissiveTexture
        copy.emissiveIntensity = emissiveIntensity
        copy.occlusionTexture = occlusionTexture
        copy.occlusionStrength = occlusionStrength
        copy.clearCoat = clearCoat
        copy.sheen = sheen
        copy.subsurface = subsurface
        copy.anisotropy = anisotropy
        copy.ior = ior
        copy.transmission = transmission
        copy.thickness = thickness
        copy.attenuationColor = attenuationColor
        copy.attenuationDistance = attenuationDistance
        copy.isDoubleSided = isDoubleSided
        copy.alphaMode = alphaMode
        copy.alphaCutoff = alphaCutoff
        copy.receivesShadow = receivesShadow
        copy.castsShadow = castsShadow
        return copy
    }
    
    /// Validates material settings.
    public func validate() -> [String] {
        var warnings: [String] = []
        
        if roughness < 0 || roughness > 1 {
            warnings.append("Roughness should be between 0 and 1")
        }
        
        if metallic < 0 || metallic > 1 {
            warnings.append("Metallic should be between 0 and 1")
        }
        
        if transmission > 0 && alphaMode != .blend {
            warnings.append("Transmission materials should use blend alpha mode")
        }
        
        if emissiveIntensity < 0 {
            warnings.append("Emissive intensity should be non-negative")
        }
        
        return warnings
    }
}
