//
//  ARMath.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import simd

// MARK: - Constants

/// Mathematical constants.
public enum ARMathConstants {
    /// Pi
    public static let pi: Float = .pi
    
    /// Two Pi
    public static let twoPi: Float = .pi * 2
    
    /// Half Pi
    public static let halfPi: Float = .pi / 2
    
    /// Degrees to radians conversion factor
    public static let deg2Rad: Float = .pi / 180
    
    /// Radians to degrees conversion factor
    public static let rad2Deg: Float = 180 / .pi
    
    /// Small epsilon for float comparisons
    public static let epsilon: Float = 1e-6
    
    /// Golden ratio
    public static let goldenRatio: Float = 1.618033988749895
}

// MARK: - Angle Conversions

/// Converts degrees to radians.
@inlinable
public func radians(_ degrees: Float) -> Float {
    degrees * ARMathConstants.deg2Rad
}

/// Converts radians to degrees.
@inlinable
public func degrees(_ radians: Float) -> Float {
    radians * ARMathConstants.rad2Deg
}

// MARK: - Interpolation

/// Linear interpolation between two values.
@inlinable
public func lerp(_ a: Float, _ b: Float, t: Float) -> Float {
    a + (b - a) * t
}

/// Smooth interpolation using smoothstep.
@inlinable
public func smoothstep(_ edge0: Float, _ edge1: Float, x: Float) -> Float {
    let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
    return t * t * (3 - 2 * t)
}

/// Smoother interpolation using smootherstep.
@inlinable
public func smootherstep(_ edge0: Float, _ edge1: Float, x: Float) -> Float {
    let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
    return t * t * t * (t * (t * 6 - 15) + 10)
}

/// Inverse lerp - finds t given a result.
@inlinable
public func inverseLerp(_ a: Float, _ b: Float, value: Float) -> Float {
    guard abs(b - a) > ARMathConstants.epsilon else { return 0 }
    return (value - a) / (b - a)
}

/// Remaps a value from one range to another.
@inlinable
public func remap(_ value: Float, from: ClosedRange<Float>, to: ClosedRange<Float>) -> Float {
    let t = inverseLerp(from.lowerBound, from.upperBound, value: value)
    return lerp(to.lowerBound, to.upperBound, t: t)
}

// MARK: - Clamping

/// Clamps a value between min and max.
@inlinable
public func clamp(_ value: Float, min minVal: Float, max maxVal: Float) -> Float {
    max(minVal, min(maxVal, value))
}

/// Clamps a value to 0...1 range.
@inlinable
public func saturate(_ value: Float) -> Float {
    max(0, min(1, value))
}

/// Wraps a value to a range.
@inlinable
public func wrap(_ value: Float, min minVal: Float, max maxVal: Float) -> Float {
    let range = maxVal - minVal
    var result = value
    while result < minVal { result += range }
    while result >= maxVal { result -= range }
    return result
}

/// Wraps an angle to -π...π range.
@inlinable
public func normalizeAngle(_ angle: Float) -> Float {
    var result = angle
    while result > Float.pi { result -= ARMathConstants.twoPi }
    while result < -Float.pi { result += ARMathConstants.twoPi }
    return result
}

// MARK: - Vector Operations

/// Linear interpolation for SIMD3.
@inlinable
public func lerp(_ a: SIMD3<Float>, _ b: SIMD3<Float>, t: Float) -> SIMD3<Float> {
    a + (b - a) * t
}

/// Reflects a vector off a surface.
@inlinable
public func reflect(_ incident: SIMD3<Float>, normal: SIMD3<Float>) -> SIMD3<Float> {
    incident - 2 * dot(incident, normal) * normal
}

/// Refracts a vector through a surface.
@inlinable
public func refract(_ incident: SIMD3<Float>, normal: SIMD3<Float>, eta: Float) -> SIMD3<Float> {
    let nDotI = dot(normal, incident)
    let k = 1 - eta * eta * (1 - nDotI * nDotI)
    
    if k < 0 {
        return SIMD3<Float>(0, 0, 0)
    }
    
    return eta * incident - (eta * nDotI + sqrt(k)) * normal
}

/// Projects a vector onto another vector.
@inlinable
public func project(_ v: SIMD3<Float>, onto target: SIMD3<Float>) -> SIMD3<Float> {
    let sqrLen = length_squared(target)
    guard sqrLen > ARMathConstants.epsilon else { return .zero }
    return target * (dot(v, target) / sqrLen)
}

/// Projects a vector onto a plane.
@inlinable
public func projectOnPlane(_ v: SIMD3<Float>, normal: SIMD3<Float>) -> SIMD3<Float> {
    v - project(v, onto: normal)
}

/// Calculates the signed angle between two vectors around an axis.
@inlinable
public func signedAngle(from: SIMD3<Float>, to: SIMD3<Float>, axis: SIMD3<Float>) -> Float {
    let unsignedAngle = acos(clamp(dot(normalize(from), normalize(to)), min: -1, max: 1))
    let crossProduct = cross(from, to)
    let sign = dot(axis, crossProduct) < 0 ? Float(-1) : Float(1)
    return unsignedAngle * sign
}

// MARK: - Matrix Operations

/// Creates a look-at matrix.
public func lookAt(eye: SIMD3<Float>, target: SIMD3<Float>, up: SIMD3<Float>) -> simd_float4x4 {
    let forward = normalize(target - eye)
    let right = normalize(cross(forward, up))
    let newUp = cross(right, forward)
    
    var matrix = simd_float4x4(1)
    matrix.columns.0 = SIMD4<Float>(right.x, newUp.x, -forward.x, 0)
    matrix.columns.1 = SIMD4<Float>(right.y, newUp.y, -forward.y, 0)
    matrix.columns.2 = SIMD4<Float>(right.z, newUp.z, -forward.z, 0)
    matrix.columns.3 = SIMD4<Float>(-dot(right, eye), -dot(newUp, eye), dot(forward, eye), 1)
    
    return matrix
}

/// Creates a perspective projection matrix.
public func perspective(fovY: Float, aspect: Float, near: Float, far: Float) -> simd_float4x4 {
    let yScale = 1 / tan(fovY * 0.5)
    let xScale = yScale / aspect
    let zRange = far - near
    
    var matrix = simd_float4x4(0)
    matrix.columns.0.x = xScale
    matrix.columns.1.y = yScale
    matrix.columns.2.z = -(far + near) / zRange
    matrix.columns.2.w = -1
    matrix.columns.3.z = -2 * far * near / zRange
    
    return matrix
}

/// Creates an orthographic projection matrix.
public func orthographic(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> simd_float4x4 {
    var matrix = simd_float4x4(1)
    matrix.columns.0.x = 2 / (right - left)
    matrix.columns.1.y = 2 / (top - bottom)
    matrix.columns.2.z = -2 / (far - near)
    matrix.columns.3.x = -(right + left) / (right - left)
    matrix.columns.3.y = -(top + bottom) / (top - bottom)
    matrix.columns.3.z = -(far + near) / (far - near)
    
    return matrix
}

/// Decomposes a transform matrix into translation, rotation, and scale.
public func decompose(_ matrix: simd_float4x4) -> (translation: SIMD3<Float>, rotation: simd_quatf, scale: SIMD3<Float>) {
    let translation = SIMD3<Float>(matrix.columns.3.x, matrix.columns.3.y, matrix.columns.3.z)
    
    let scaleX = length(SIMD3<Float>(matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z))
    let scaleY = length(SIMD3<Float>(matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z))
    let scaleZ = length(SIMD3<Float>(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z))
    let scale = SIMD3<Float>(scaleX, scaleY, scaleZ)
    
    var rotMatrix = simd_float3x3()
    rotMatrix.columns.0 = SIMD3<Float>(matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z) / scaleX
    rotMatrix.columns.1 = SIMD3<Float>(matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z) / scaleY
    rotMatrix.columns.2 = SIMD3<Float>(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z) / scaleZ
    let rotation = simd_quatf(rotMatrix)
    
    return (translation, rotation, scale)
}

/// Composes a transform matrix from translation, rotation, and scale.
public func compose(translation: SIMD3<Float>, rotation: simd_quatf, scale: SIMD3<Float>) -> simd_float4x4 {
    let rotMatrix = simd_float3x3(rotation)
    
    var matrix = simd_float4x4(1)
    matrix.columns.0 = SIMD4<Float>(rotMatrix.columns.0 * scale.x, 0)
    matrix.columns.1 = SIMD4<Float>(rotMatrix.columns.1 * scale.y, 0)
    matrix.columns.2 = SIMD4<Float>(rotMatrix.columns.2 * scale.z, 0)
    matrix.columns.3 = SIMD4<Float>(translation, 1)
    
    return matrix
}

// MARK: - Quaternion Operations

/// Creates a quaternion from euler angles (XYZ order).
public func quaternion(euler: SIMD3<Float>) -> simd_quatf {
    let halfX = euler.x * 0.5
    let halfY = euler.y * 0.5
    let halfZ = euler.z * 0.5
    
    let cx = cos(halfX)
    let sx = sin(halfX)
    let cy = cos(halfY)
    let sy = sin(halfY)
    let cz = cos(halfZ)
    let sz = sin(halfZ)
    
    return simd_quatf(
        ix: sx * cy * cz - cx * sy * sz,
        iy: cx * sy * cz + sx * cy * sz,
        iz: cx * cy * sz - sx * sy * cz,
        r: cx * cy * cz + sx * sy * sz
    )
}

/// Extracts euler angles from a quaternion (XYZ order).
public func euler(quaternion q: simd_quatf) -> SIMD3<Float> {
    let sinr_cosp = 2 * (q.real * q.imag.x + q.imag.y * q.imag.z)
    let cosr_cosp = 1 - 2 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)
    let x = atan2(sinr_cosp, cosr_cosp)
    
    let sinp = 2 * (q.real * q.imag.y - q.imag.z * q.imag.x)
    let y: Float
    if abs(sinp) >= 1 {
        y = copysign(.pi / 2, sinp)
    } else {
        y = asin(sinp)
    }
    
    let siny_cosp = 2 * (q.real * q.imag.z + q.imag.x * q.imag.y)
    let cosy_cosp = 1 - 2 * (q.imag.y * q.imag.y + q.imag.z * q.imag.z)
    let z = atan2(siny_cosp, cosy_cosp)
    
    return SIMD3<Float>(x, y, z)
}

/// Rotates a quaternion towards another.
public func rotateTowards(_ from: simd_quatf, to: simd_quatf, maxAngle: Float) -> simd_quatf {
    let angle = acos(min(abs(simd_dot(from, to)), 1)) * 2
    
    if angle < ARMathConstants.epsilon {
        return to
    }
    
    let t = min(1, maxAngle / angle)
    return simd_slerp(from, to, t)
}

// MARK: - Noise Functions

/// Simple pseudo-random hash function.
@inlinable
public func hash(_ n: Float) -> Float {
    let x = sin(n) * 43758.5453123
    return x - floor(x)
}

/// 2D noise function.
public func noise2D(_ x: Float, _ y: Float) -> Float {
    let i = floor(x)
    let j = floor(y)
    let u = x - i
    let v = y - j
    
    let a = hash(i + j * 57)
    let b = hash(i + 1 + j * 57)
    let c = hash(i + (j + 1) * 57)
    let d = hash(i + 1 + (j + 1) * 57)
    
    let smoothU = smoothstep(0, 1, x: u)
    let smoothV = smoothstep(0, 1, x: v)
    
    return lerp(
        lerp(a, b, t: smoothU),
        lerp(c, d, t: smoothU),
        t: smoothV
    )
}

// MARK: - Geometry

/// Calculates the area of a triangle.
@inlinable
public func triangleArea(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>) -> Float {
    length(cross(b - a, c - a)) * 0.5
}

/// Calculates barycentric coordinates.
public func barycentric(point: SIMD3<Float>, triangle: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)) -> SIMD3<Float> {
    let (a, b, c) = triangle
    let v0 = b - a
    let v1 = c - a
    let v2 = point - a
    
    let dot00 = dot(v0, v0)
    let dot01 = dot(v0, v1)
    let dot02 = dot(v0, v2)
    let dot11 = dot(v1, v1)
    let dot12 = dot(v1, v2)
    
    let invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
    let u = (dot11 * dot02 - dot01 * dot12) * invDenom
    let v = (dot00 * dot12 - dot01 * dot02) * invDenom
    
    return SIMD3<Float>(1 - u - v, u, v)
}

/// Checks if a point is inside a triangle.
public func pointInTriangle(point: SIMD3<Float>, triangle: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)) -> Bool {
    let bary = barycentric(point: point, triangle: triangle)
    return bary.x >= 0 && bary.y >= 0 && bary.z >= 0
}
