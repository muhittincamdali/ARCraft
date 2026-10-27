import simd

/// A point on a real-world surface and the surface's normal, from a raycast, a spatial tap on a
/// scene-reconstruction mesh or a plane anchor.
public struct SurfaceHit: Sendable, Hashable {
    /// The hit point in world space, in meters.
    public var position: SIMD3<Float>
    /// The surface normal at the hit point, pointing away from the surface. Need not be unit length.
    public var normal: SIMD3<Float>

    /// Creates a surface hit.
    public init(position: SIMD3<Float>, normal: SIMD3<Float>) {
        self.position = position
        self.normal = normal
    }
}

/// How a surface is oriented relative to gravity.
public enum SurfaceOrientation: String, CaseIterable, Codable, Sendable, Hashable {
    /// Faces up: floors, tables, seats.
    case floor
    /// Faces down.
    case ceiling
    /// Vertical.
    case wall
    /// Anything in between.
    case slope

    /// Classifies a normal. `tolerance` (radians, clamped to `0...π/4`) is how far from exactly
    /// up, down or horizontal a normal may lean. `nil` for a zero or non-finite normal.
    public init?(normal: SIMD3<Float>, tolerance: Float = .pi / 12) {
        guard let angle = SpatialMath.angle(between: normal, and: SpatialMath.worldUp) else { return nil }
        let tolerance = tolerance.isFinite ? min(max(tolerance, 0), .pi / 4) : .pi / 12
        if angle <= tolerance {
            self = .floor
        } else if angle >= .pi - tolerance {
            self = .ceiling
        } else if abs(angle - .pi / 2) <= tolerance {
            self = .wall
        } else {
            self = .slope
        }
    }
}

/// Where and how to put content on a surface: the result of ``PlacementSolver``.
public struct Placement: Sendable, Hashable {
    /// The content's world pose. Its +Z axis is the content's front (the USD convention).
    public var pose: Pose
    /// The kind of surface the content was placed on.
    public var surface: SurfaceOrientation
}

/// Why ``PlacementSolver`` could not place content.
public enum PlacementError: Error, Sendable, Hashable {
    /// The hit position or normal is zero, NaN or infinite.
    case invalidHit
    /// The viewer position is NaN or infinite.
    case invalidViewer
    /// The surface is of a kind that ``PlacementOptions/allowedSurfaces`` excludes.
    case surfaceNotAllowed(SurfaceOrientation)
}

/// The rules ``PlacementSolver`` applies.
public struct PlacementOptions: Sendable, Hashable {
    /// The kinds of surface content may be placed on.
    public var allowedSurfaces: Set<SurfaceOrientation>
    /// How far a normal may lean and still count as floor, ceiling or wall, in radians.
    public var surfaceTolerance: Float
    /// Snap the position to a grid with this spacing in meters, measured in the surface plane.
    /// `nil`, or a value below 1 mm, turns snapping off.
    public var gridSize: Float?
    /// On floors and ceilings, snap the turn toward the viewer to multiples of this angle in
    /// radians. `nil`, or a value below 0.1°, turns snapping off.
    public var rotationStep: Float?
    /// Lift the content off the surface along its normal, in meters.
    public var surfaceOffset: Float
    /// On floors, tilt the content with a surface that is not quite level instead of keeping it
    /// upright. Slopes always tilt.
    public var alignsToSurfaceNormal: Bool

    /// Creates placement options.
    public init(allowedSurfaces: Set<SurfaceOrientation> = [.floor, .wall], surfaceTolerance: Float = .pi / 12,
                gridSize: Float? = nil, rotationStep: Float? = nil, surfaceOffset: Float = 0,
                alignsToSurfaceNormal: Bool = false) {
        self.allowedSurfaces = allowedSurfaces
        self.surfaceTolerance = surfaceTolerance
        self.gridSize = gridSize.flatMap { $0.isFinite && $0 >= 0.001 ? $0 : nil }
        self.rotationStep = rotationStep.flatMap { $0.isFinite && $0 >= .pi / 1800 ? $0 : nil }
        self.surfaceOffset = surfaceOffset.isFinite ? surfaceOffset : 0
        self.alignsToSurfaceNormal = alignsToSurfaceNormal
    }
}

/// Computes a world pose for content placed on a real surface.
///
/// On a floor or a table the content stands upright and turns to face the viewer. On a wall it
/// lies flat against the wall, facing out, upright. Grid and rotation snapping are optional.
///
/// ```swift
/// let solver = PlacementSolver(options: .init(gridSize: 0.1, rotationStep: .pi / 4))
/// let placement = try solver.place(on: SurfaceHit(position: hitPoint, normal: hitNormal),
///                                  facing: devicePosition)
/// entity.setPose(placement.pose)
/// ```
public struct PlacementSolver: Sendable, Hashable {
    /// The rules in use.
    public var options: PlacementOptions

    /// Creates a solver.
    public init(options: PlacementOptions = PlacementOptions()) {
        self.options = options
    }

    /// Places content at `hit`, turned toward `viewer` (usually the device or head position).
    public func place(on hit: SurfaceHit, facing viewer: SIMD3<Float>) throws(PlacementError) -> Placement {
        guard hit.position.isFinite, let normal = SpatialMath.normalized(hit.normal),
              let surface = SurfaceOrientation(normal: normal, tolerance: options.surfaceTolerance) else {
            throw .invalidHit
        }
        guard viewer.isFinite else { throw .invalidViewer }
        guard options.allowedSurfaces.contains(surface) else { throw .surfaceNotAllowed(surface) }
        let lifted = hit.position + normal * options.surfaceOffset
        let pose = switch surface {
        case .wall: wallPose(at: lifted, normal: normal)
        case .floor: standingPose(at: lifted, up: options.alignsToSurfaceNormal ? normal : SpatialMath.worldUp, viewer: viewer)
        case .ceiling: standingPose(at: lifted, up: SpatialMath.worldUp, viewer: viewer)
        case .slope: standingPose(at: lifted, up: normal, viewer: viewer)
        }
        return Placement(pose: pose, surface: surface)
    }

    private func standingPose(at position: SIMD3<Float>, up: SIMD3<Float>, viewer: SIMD3<Float>) -> Pose {
        let snapped = snapped(position, along: planeAxes(up: up))
        let (side, reference) = planeAxes(up: up)
        let toViewer = SpatialMath.projected(viewer - snapped, ontoPlaneWithNormal: up)
        var yaw = SpatialMath.normalized(toViewer).map { atan2(simd_dot($0, side), simd_dot($0, reference)) } ?? 0
        if let step = options.rotationStep {
            yaw = (yaw / step).rounded() * step
        }
        let forward = side * sin(yaw) + reference * cos(yaw)
        let orientation = SpatialMath.lookRotation(forward: forward, up: up) ?? simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        return Pose(position: snapped, orientation: orientation)
    }

    private func wallPose(at position: SIMD3<Float>, normal: SIMD3<Float>) -> Pose {
        let side = SpatialMath.normalized(simd_cross(SpatialMath.worldUp, normal)) ?? SIMD3(1, 0, 0)
        let up = simd_cross(normal, side)
        let orientation = SpatialMath.lookRotation(forward: normal, up: up) ?? simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        return Pose(position: snapped(position, along: (side, up)), orientation: orientation)
    }

    /// Two unit axes spanning the plane perpendicular to `up`: a side axis and a reference axis
    /// that is world +Z flattened into the plane (or world +X when +Z is parallel to `up`).
    private func planeAxes(up: SIMD3<Float>) -> (side: SIMD3<Float>, reference: SIMD3<Float>) {
        let reference = SpatialMath.normalized(SpatialMath.projected(SIMD3(0, 0, 1), ontoPlaneWithNormal: up))
            ?? SpatialMath.normalized(SpatialMath.projected(SIMD3(1, 0, 0), ontoPlaneWithNormal: up))
            ?? SIMD3(0, 0, 1)
        return (simd_cross(up, reference), reference)
    }

    /// Rounds the position's coordinates along two in-plane axes to the grid.
    private func snapped(_ position: SIMD3<Float>, along axes: (SIMD3<Float>, SIMD3<Float>)) -> SIMD3<Float> {
        guard let grid = options.gridSize else { return position }
        var result = position
        for axis in [axes.0, axes.1] {
            let coordinate = simd_dot(position, axis)
            let rounded = (coordinate / grid).rounded() * grid
            guard rounded.isFinite else { return position }
            result += (rounded - coordinate) * axis
        }
        return result
    }
}
