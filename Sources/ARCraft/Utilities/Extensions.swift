//
//  Extensions.swift
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

// MARK: - SIMD3 Extensions

extension SIMD3 where Scalar == Float {
    /// Zero vector
    public static var zero: SIMD3<Float> {
        SIMD3<Float>(0, 0, 0)
    }
    
    /// One vector
    public static var one: SIMD3<Float> {
        SIMD3<Float>(1, 1, 1)
    }
    
    /// Unit X vector
    public static var unitX: SIMD3<Float> {
        SIMD3<Float>(1, 0, 0)
    }
    
    /// Unit Y vector
    public static var unitY: SIMD3<Float> {
        SIMD3<Float>(0, 1, 0)
    }
    
    /// Unit Z vector
    public static var unitZ: SIMD3<Float> {
        SIMD3<Float>(0, 0, 1)
    }
    
    /// Up direction
    public static var up: SIMD3<Float> {
        SIMD3<Float>(0, 1, 0)
    }
    
    /// Down direction
    public static var down: SIMD3<Float> {
        SIMD3<Float>(0, -1, 0)
    }
    
    /// Forward direction
    public static var forward: SIMD3<Float> {
        SIMD3<Float>(0, 0, -1)
    }
    
    /// Backward direction
    public static var backward: SIMD3<Float> {
        SIMD3<Float>(0, 0, 1)
    }
    
    /// Right direction
    public static var right: SIMD3<Float> {
        SIMD3<Float>(1, 0, 0)
    }
    
    /// Left direction
    public static var left: SIMD3<Float> {
        SIMD3<Float>(-1, 0, 0)
    }
    
    /// Magnitude of the vector
    public var magnitude: Float {
        length(self)
    }
    
    /// Squared magnitude
    public var sqrMagnitude: Float {
        length_squared(self)
    }
    
    /// Normalized version of this vector
    public var normalized: SIMD3<Float> {
        let mag = magnitude
        guard mag > 0 else { return .zero }
        return self / mag
    }
    
    /// Creates from a uniform value
    public init(_ value: Float) {
        self.init(value, value, value)
    }
    
    /// Linear interpolation
    public func lerp(to target: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        self + (target - self) * t
    }
    
    /// Clamps each component
    public func clamped(min: SIMD3<Float>, max: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3<Float>(
            Swift.max(min.x, Swift.min(max.x, x)),
            Swift.max(min.y, Swift.min(max.y, y)),
            Swift.max(min.z, Swift.min(max.z, z))
        )
    }
    
    /// Distance to another point
    public func distance(to other: SIMD3<Float>) -> Float {
        simd.distance(self, other)
    }
    
    /// Angle to another vector in radians
    public func angle(to other: SIMD3<Float>) -> Float {
        let dot = simd.dot(normalized, other.normalized)
        return acos(Swift.max(-1, Swift.min(1, dot)))
    }
}

// MARK: - SIMD4 Extensions

extension SIMD4 where Scalar == Float {
    /// Zero vector
    public static var zero: SIMD4<Float> {
        SIMD4<Float>(0, 0, 0, 0)
    }
    
    /// One vector
    public static var one: SIMD4<Float> {
        SIMD4<Float>(1, 1, 1, 1)
    }
    
    /// Creates from SIMD3 with w component
    public init(_ xyz: SIMD3<Float>, _ w: Float) {
        self.init(xyz.x, xyz.y, xyz.z, w)
    }
    
    /// XYZ components as SIMD3
    public var xyz: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}

// MARK: - simd_float4x4 Extensions

extension simd_float4x4 {
    /// Identity matrix
    public static var identity: simd_float4x4 {
        matrix_identity_float4x4
    }
    
    /// Creates a translation matrix
    public static func translation(_ t: SIMD3<Float>) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = SIMD4<Float>(t.x, t.y, t.z, 1)
        return matrix
    }
    
    /// Creates a scale matrix
    public static func scale(_ s: SIMD3<Float>) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.0.x = s.x
        matrix.columns.1.y = s.y
        matrix.columns.2.z = s.z
        return matrix
    }
    
    /// Creates a uniform scale matrix
    public static func scale(_ s: Float) -> simd_float4x4 {
        scale(SIMD3<Float>(s, s, s))
    }
    
    /// Creates a rotation matrix around X axis
    public static func rotationX(_ angle: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.1.y = cos(angle)
        matrix.columns.1.z = sin(angle)
        matrix.columns.2.y = -sin(angle)
        matrix.columns.2.z = cos(angle)
        return matrix
    }
    
    /// Creates a rotation matrix around Y axis
    public static func rotationY(_ angle: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.0.x = cos(angle)
        matrix.columns.0.z = -sin(angle)
        matrix.columns.2.x = sin(angle)
        matrix.columns.2.z = cos(angle)
        return matrix
    }
    
    /// Creates a rotation matrix around Z axis
    public static func rotationZ(_ angle: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.0.x = cos(angle)
        matrix.columns.0.y = sin(angle)
        matrix.columns.1.x = -sin(angle)
        matrix.columns.1.y = cos(angle)
        return matrix
    }
    
    /// Creates rotation from quaternion
    public static func rotation(_ q: simd_quatf) -> simd_float4x4 {
        simd_float4x4(q)
    }
    
    /// Translation component
    public var translation: SIMD3<Float> {
        get { SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z) }
        set {
            columns.3.x = newValue.x
            columns.3.y = newValue.y
            columns.3.z = newValue.z
        }
    }
    
    /// Forward direction (-Z)
    public var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z))
    }
    
    /// Up direction (Y)
    public var up: SIMD3<Float> {
        normalize(SIMD3<Float>(columns.1.x, columns.1.y, columns.1.z))
    }
    
    /// Right direction (X)
    public var right: SIMD3<Float> {
        normalize(SIMD3<Float>(columns.0.x, columns.0.y, columns.0.z))
    }
    
    /// Upper-left 3x3 portion
    public var upperLeft3x3: simd_float3x3 {
        simd_float3x3(
            SIMD3<Float>(columns.0.x, columns.0.y, columns.0.z),
            SIMD3<Float>(columns.1.x, columns.1.y, columns.1.z),
            SIMD3<Float>(columns.2.x, columns.2.y, columns.2.z)
        )
    }
}

// MARK: - simd_quatf Extensions

extension simd_quatf {
    /// Identity quaternion
    public static var identity: simd_quatf {
        simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    }
    
    /// Creates from axis and angle
    public init(axis: SIMD3<Float>, angle: Float) {
        let halfAngle = angle * 0.5
        let s = sin(halfAngle)
        self.init(ix: axis.x * s, iy: axis.y * s, iz: axis.z * s, r: cos(halfAngle))
    }
    
    /// Creates quaternion that rotates from one direction to another
    public init(from: SIMD3<Float>, to: SIMD3<Float>) {
        let normalizedFrom = normalize(from)
        let normalizedTo = normalize(to)
        
        let cosAngle = dot(normalizedFrom, normalizedTo)
        
        if cosAngle >= 1 - 1e-6 {
            self = .identity
        } else if cosAngle <= -1 + 1e-6 {
            var axis = cross(SIMD3<Float>(1, 0, 0), normalizedFrom)
            if length_squared(axis) < 1e-6 {
                axis = cross(SIMD3<Float>(0, 1, 0), normalizedFrom)
            }
            self.init(axis: normalize(axis), angle: .pi)
        } else {
            let axis = normalize(cross(normalizedFrom, normalizedTo))
            let angle = acos(cosAngle)
            self.init(axis: axis, angle: angle)
        }
    }
    
    /// Euler angles (XYZ order)
    public var eulerAngles: SIMD3<Float> {
        ARCraft.euler(quaternion: self)
    }
    
    /// Creates from euler angles
    public init(euler: SIMD3<Float>) {
        self = ARCraft.quaternion(euler: euler)
    }
    
    /// Inverted quaternion
    public var inverted: simd_quatf {
        simd_inverse(self)
    }
    
    /// Forward direction
    public var forward: SIMD3<Float> {
        act(SIMD3<Float>(0, 0, -1))
    }
    
    /// Up direction
    public var up: SIMD3<Float> {
        act(SIMD3<Float>(0, 1, 0))
    }
    
    /// Right direction
    public var right: SIMD3<Float> {
        act(SIMD3<Float>(1, 0, 0))
    }
}

// MARK: - Float Extensions

extension Float {
    /// Clamps to 0...1 range
    public var saturated: Float {
        max(0, min(1, self))
    }
    
    /// Converts degrees to radians
    public var radians: Float {
        self * .pi / 180
    }
    
    /// Converts radians to degrees
    public var degrees: Float {
        self * 180 / .pi
    }
    
    /// Remaps from one range to another
    public func remap(from: ClosedRange<Float>, to: ClosedRange<Float>) -> Float {
        ARCraft.remap(self, from: from, to: to)
    }
}

// MARK: - CGPoint Extensions

extension CGPoint {
    /// Zero point
    public static var zero: CGPoint {
        CGPoint(x: 0, y: 0)
    }
    
    /// Creates from SIMD2
    public init(_ simd: SIMD2<Float>) {
        self.init(x: CGFloat(simd.x), y: CGFloat(simd.y))
    }
    
    /// Converts to SIMD2
    public var simd: SIMD2<Float> {
        SIMD2<Float>(Float(x), Float(y))
    }
    
    /// Distance to another point
    public func distance(to other: CGPoint) -> CGFloat {
        let dx = other.x - x
        let dy = other.y - y
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Linear interpolation
    public func lerp(to target: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(
            x: x + (target.x - x) * t,
            y: y + (target.y - y) * t
        )
    }
}

// MARK: - CGSize Extensions

extension CGSize {
    /// Aspect ratio (width / height)
    public var aspectRatio: CGFloat {
        guard height != 0 else { return 0 }
        return width / height
    }
    
    /// Creates from SIMD2
    public init(_ simd: SIMD2<Float>) {
        self.init(width: CGFloat(simd.x), height: CGFloat(simd.y))
    }
    
    /// Converts to SIMD2
    public var simd: SIMD2<Float> {
        SIMD2<Float>(Float(width), Float(height))
    }
}

// MARK: - Array Extensions

extension Array where Element == SIMD3<Float> {
    /// Calculates the centroid of points
    public var centroid: SIMD3<Float> {
        guard !isEmpty else { return .zero }
        let sum = reduce(.zero, +)
        return sum / Float(count)
    }
    
    /// Calculates axis-aligned bounding box
    public var bounds: (min: SIMD3<Float>, max: SIMD3<Float>) {
        guard let first = first else {
            return (.zero, .zero)
        }
        
        var minPoint = first
        var maxPoint = first
        
        for point in self {
            minPoint = simd.min(minPoint, point)
            maxPoint = simd.max(maxPoint, point)
        }
        
        return (minPoint, maxPoint)
    }
}

// MARK: - Collection Extensions

extension Collection {
    /// Safe subscript that returns nil for out-of-bounds indices
    public subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    /// Converts to milliseconds
    public var milliseconds: Double {
        self * 1000
    }
    
    /// Creates from milliseconds
    public static func milliseconds(_ ms: Double) -> TimeInterval {
        ms / 1000
    }
}

// MARK: - UUID Extensions

extension UUID {
    /// Short string representation (first 8 characters)
    public var shortString: String {
        String(uuidString.prefix(8))
    }
}
