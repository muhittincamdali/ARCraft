//
//  LightEntity.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Light Type

/// Type of light source.
public enum LightType: String, Sendable, CaseIterable {
    /// Directional light (like the sun)
    case directional
    
    /// Point light (omnidirectional)
    case point
    
    /// Spot light (cone-shaped)
    case spot
    
    /// Area light (rectangular emitter)
    case area
    
    /// Ambient light (global fill)
    case ambient
    
    /// Description
    public var description: String {
        switch self {
        case .directional: return "Directional"
        case .point: return "Point"
        case .spot: return "Spot"
        case .area: return "Area"
        case .ambient: return "Ambient"
        }
    }
}

// MARK: - Light Color

/// Represents a light color with intensity.
public struct LightColor: Sendable, Equatable {
    /// Red component (0-1)
    public var red: Float
    
    /// Green component (0-1)
    public var green: Float
    
    /// Blue component (0-1)
    public var blue: Float
    
    /// Creates a light color
    public init(red: Float, green: Float, blue: Float) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    /// Creates from RGB values (0-255)
    public init(r: Int, g: Int, b: Int) {
        self.red = Float(r) / 255.0
        self.green = Float(g) / 255.0
        self.blue = Float(b) / 255.0
    }
    
    /// Creates from color temperature in Kelvin
    public init(temperature: Float) {
        // Approximate color temperature to RGB conversion
        let temp = temperature / 100.0
        
        if temp <= 66 {
            red = 1.0
            green = max(0, min(1, (0.390081578769 * log(temp) - 0.631841443788)))
            
            if temp <= 19 {
                blue = 0
            } else {
                blue = max(0, min(1, (0.543206789110 * log(temp - 10) - 1.196254089957)))
            }
        } else {
            red = max(0, min(1, (1.292936186062 * pow(temp - 60, -0.133204759810))))
            green = max(0, min(1, (1.129890860895 * pow(temp - 60, -0.075514849868))))
            blue = 1.0
        }
    }
    
    /// White light
    public static let white = LightColor(red: 1, green: 1, blue: 1)
    
    /// Warm white (incandescent)
    public static let warmWhite = LightColor(temperature: 2700)
    
    /// Cool white (daylight)
    public static let coolWhite = LightColor(temperature: 6500)
    
    /// Soft warm
    public static let softWarm = LightColor(temperature: 3000)
    
    /// Daylight
    public static let daylight = LightColor(temperature: 5500)
    
    /// As SIMD3
    public var simd: SIMD3<Float> {
        SIMD3<Float>(red, green, blue)
    }
}

// MARK: - Shadow Settings

/// Settings for light shadows.
public struct ShadowSettings: Sendable, Equatable {
    /// Whether shadows are enabled
    public var enabled: Bool
    
    /// Shadow map resolution
    public var resolution: Int
    
    /// Shadow bias to prevent acne
    public var bias: Float
    
    /// Shadow softness (0 = hard, 1 = soft)
    public var softness: Float
    
    /// Maximum shadow distance
    public var maxDistance: Float
    
    /// Number of cascade levels
    public var cascadeCount: Int
    
    /// Creates shadow settings
    public init(
        enabled: Bool = true,
        resolution: Int = 1024,
        bias: Float = 0.001,
        softness: Float = 0.5,
        maxDistance: Float = 50,
        cascadeCount: Int = 4
    ) {
        self.enabled = enabled
        self.resolution = resolution
        self.bias = bias
        self.softness = softness
        self.maxDistance = maxDistance
        self.cascadeCount = cascadeCount
    }
    
    /// Default settings
    public static let `default` = ShadowSettings()
    
    /// High quality shadows
    public static let highQuality = ShadowSettings(
        resolution: 2048,
        softness: 0.3,
        cascadeCount: 4
    )
    
    /// Performance-focused shadows
    public static let performance = ShadowSettings(
        resolution: 512,
        softness: 0,
        cascadeCount: 2
    )
    
    /// No shadows
    public static let none = ShadowSettings(enabled: false)
}

// MARK: - Light Entity

/// Entity representing a light source.
///
/// `LightEntity` provides various types of lighting for AR scenes,
/// including directional, point, spot, and area lights.
///
/// ## Example
///
/// ```swift
/// // Create a directional light (sun)
/// let sun = LightEntity.directionalLight(
///     color: .daylight,
///     intensity: 1000
/// )
/// sun.transform.rotation = simd_quatf(angle: -.pi/4, axis: SIMD3(1, 0, 0))
///
/// // Create a point light
/// let lamp = LightEntity.pointLight(
///     color: .warmWhite,
///     intensity: 500,
///     radius: 5
/// )
/// lamp.transform.position = SIMD3(0, 2, 0)
/// ```
public class LightEntity: ARCraftEntity {
    
    // MARK: - Properties
    
    /// Type of light
    public let lightType: LightType
    
    /// Light color
    public var color: LightColor
    
    /// Light intensity in lumens (point/spot) or lux (directional)
    public var intensity: Float
    
    /// Whether the light is enabled
    public var isLightEnabled: Bool = true
    
    /// Attenuation radius for point/spot lights
    public var attenuationRadius: Float
    
    /// Inner cone angle for spot lights (radians)
    public var innerConeAngle: Float
    
    /// Outer cone angle for spot lights (radians)
    public var outerConeAngle: Float
    
    /// Area size for area lights
    public var areaSize: SIMD2<Float>
    
    /// Shadow settings
    public var shadowSettings: ShadowSettings
    
    /// Indirect lighting multiplier
    public var indirectMultiplier: Float = 1.0
    
    /// Whether this light affects specular
    public var affectsSpecular: Bool = true
    
    // MARK: - Initialization
    
    /// Creates a light entity.
    public init(
        name: String = "Light",
        type: LightType,
        color: LightColor = .white,
        intensity: Float = 1000
    ) {
        self.lightType = type
        self.color = color
        self.intensity = intensity
        self.attenuationRadius = 10
        self.innerConeAngle = .pi / 6
        self.outerConeAngle = .pi / 4
        self.areaSize = SIMD2<Float>(1, 1)
        self.shadowSettings = type == .ambient ? .none : .default
        
        super.init(name: name)
        self.addTag("light")
    }
    
    // MARK: - Factory Methods
    
    /// Creates a directional light.
    public static func directionalLight(
        color: LightColor = .daylight,
        intensity: Float = 1000,
        shadows: ShadowSettings = .default
    ) -> LightEntity {
        let light = LightEntity(name: "DirectionalLight", type: .directional, color: color, intensity: intensity)
        light.shadowSettings = shadows
        return light
    }
    
    /// Creates a point light.
    public static func pointLight(
        color: LightColor = .white,
        intensity: Float = 500,
        radius: Float = 10
    ) -> LightEntity {
        let light = LightEntity(name: "PointLight", type: .point, color: color, intensity: intensity)
        light.attenuationRadius = radius
        return light
    }
    
    /// Creates a spot light.
    public static func spotLight(
        color: LightColor = .white,
        intensity: Float = 500,
        innerAngle: Float = .pi / 8,
        outerAngle: Float = .pi / 4,
        radius: Float = 10
    ) -> LightEntity {
        let light = LightEntity(name: "SpotLight", type: .spot, color: color, intensity: intensity)
        light.innerConeAngle = innerAngle
        light.outerConeAngle = outerAngle
        light.attenuationRadius = radius
        return light
    }
    
    /// Creates an area light.
    public static func areaLight(
        color: LightColor = .white,
        intensity: Float = 500,
        size: SIMD2<Float> = SIMD2<Float>(1, 1)
    ) -> LightEntity {
        let light = LightEntity(name: "AreaLight", type: .area, color: color, intensity: intensity)
        light.areaSize = size
        return light
    }
    
    /// Creates an ambient light.
    public static func ambientLight(
        color: LightColor = .white,
        intensity: Float = 100
    ) -> LightEntity {
        let light = LightEntity(name: "AmbientLight", type: .ambient, color: color, intensity: intensity)
        light.shadowSettings = .none
        return light
    }
    
    // MARK: - Direction
    
    /// Direction the light is pointing (for directional/spot)
    public var direction: SIMD3<Float> {
        -transform.forward
    }
    
    /// Sets the light direction
    public func setDirection(_ direction: SIMD3<Float>) {
        let normalizedDir = normalize(direction)
        let up = abs(normalizedDir.y) > 0.99 ? SIMD3<Float>(1, 0, 0) : SIMD3<Float>(0, 1, 0)
        let right = normalize(cross(up, -normalizedDir))
        let newUp = cross(-normalizedDir, right)
        
        let rotMatrix = simd_float3x3(right, newUp, -normalizedDir)
        transform.rotation = simd_quatf(rotMatrix)
    }
    
    // MARK: - Attenuation
    
    /// Calculates light attenuation at a distance.
    public func attenuation(at distance: Float) -> Float {
        switch lightType {
        case .directional, .ambient:
            return 1.0
            
        case .point, .area:
            if distance >= attenuationRadius {
                return 0
            }
            let normalized = 1 - (distance / attenuationRadius)
            return normalized * normalized
            
        case .spot:
            if distance >= attenuationRadius {
                return 0
            }
            let distAtten = 1 - (distance / attenuationRadius)
            return distAtten * distAtten
        }
    }
    
    /// Calculates spot light cone attenuation.
    public func coneAttenuation(direction: SIMD3<Float>) -> Float {
        guard lightType == .spot else { return 1 }
        
        let angle = acos(dot(normalize(direction), self.direction))
        
        if angle <= innerConeAngle {
            return 1.0
        } else if angle >= outerConeAngle {
            return 0.0
        } else {
            let t = (angle - innerConeAngle) / (outerConeAngle - innerConeAngle)
            return 1 - t
        }
    }
    
    // MARK: - Illumination
    
    /// Calculates illumination at a point.
    public func illumination(at point: SIMD3<Float>) -> SIMD3<Float> {
        guard isLightEnabled else { return .zero }
        
        switch lightType {
        case .ambient:
            return color.simd * intensity / 1000
            
        case .directional:
            return color.simd * intensity / 1000
            
        case .point:
            let dist = simd.distance(worldPosition, point)
            let atten = attenuation(at: dist)
            return color.simd * intensity / 1000 * atten
            
        case .spot:
            let dist = simd.distance(worldPosition, point)
            let toPoint = normalize(point - worldPosition)
            let distAtten = attenuation(at: dist)
            let coneAtten = coneAttenuation(direction: toPoint)
            return color.simd * intensity / 1000 * distAtten * coneAtten
            
        case .area:
            let dist = simd.distance(worldPosition, point)
            let atten = attenuation(at: dist)
            return color.simd * intensity / 1000 * atten
        }
    }
    
    // MARK: - Utility
    
    /// Toggles the light on/off.
    public func toggle() {
        isLightEnabled.toggle()
    }
    
    /// Fades to a target intensity.
    public func fade(to intensity: Float, duration: TimeInterval) {
        // In a real implementation, this would animate
        self.intensity = intensity
    }
    
    /// Creates a copy of this light.
    public func copy() -> LightEntity {
        let copy = LightEntity(
            name: name + "_copy",
            type: lightType,
            color: color,
            intensity: intensity
        )
        copy.transform = transform
        copy.attenuationRadius = attenuationRadius
        copy.innerConeAngle = innerConeAngle
        copy.outerConeAngle = outerConeAngle
        copy.areaSize = areaSize
        copy.shadowSettings = shadowSettings
        copy.indirectMultiplier = indirectMultiplier
        copy.affectsSpecular = affectsSpecular
        return copy
    }
}

// MARK: - Light Rig

/// A collection of lights for common setups.
public struct LightRig {
    /// Lights in the rig
    public var lights: [LightEntity]
    
    /// Creates a light rig
    public init(lights: [LightEntity]) {
        self.lights = lights
    }
    
    /// Three-point lighting setup
    public static func threePoint() -> LightRig {
        let key = LightEntity.directionalLight(color: .daylight, intensity: 1000)
        key.transform.rotation = simd_quatf(angle: -.pi/4, axis: SIMD3(1, 0.5, 0))
        key.name = "KeyLight"
        
        let fill = LightEntity.directionalLight(color: .coolWhite, intensity: 400)
        fill.transform.rotation = simd_quatf(angle: .pi/6, axis: SIMD3(1, -0.5, 0))
        fill.shadowSettings = .none
        fill.name = "FillLight"
        
        let back = LightEntity.directionalLight(color: .white, intensity: 300)
        back.transform.rotation = simd_quatf(angle: .pi * 0.8, axis: SIMD3(0, 1, 0))
        back.shadowSettings = .none
        back.name = "BackLight"
        
        return LightRig(lights: [key, fill, back])
    }
    
    /// Outdoor daylight setup
    public static func outdoor() -> LightRig {
        let sun = LightEntity.directionalLight(color: .daylight, intensity: 1200)
        sun.transform.rotation = simd_quatf(angle: -.pi/3, axis: SIMD3(1, 0.3, 0))
        sun.name = "Sun"
        
        let sky = LightEntity.ambientLight(color: LightColor(temperature: 7500), intensity: 150)
        sky.name = "SkyLight"
        
        return LightRig(lights: [sun, sky])
    }
    
    /// Indoor warm lighting
    public static func indoorWarm() -> LightRig {
        let overhead = LightEntity.pointLight(color: .warmWhite, intensity: 600, radius: 8)
        overhead.transform.position = SIMD3(0, 2.5, 0)
        overhead.name = "OverheadLight"
        
        let ambient = LightEntity.ambientLight(color: .softWarm, intensity: 80)
        ambient.name = "AmbientFill"
        
        return LightRig(lights: [overhead, ambient])
    }
}
