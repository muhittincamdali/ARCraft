# Placing Content on Surfaces

Turn a tap on a table or a wall into an upright, snapped pose, and fit models of any size.

## Overview

A raycast, a spatial tap on a scene-reconstruction mesh or a plane anchor gives you a point and a
normal. ``PlacementSolver`` decides how content should sit there:

- On a **floor** or table the content stands upright and turns to face the viewer, even if the
  surface is slightly tilted.
- On a **wall** it lies flat against the wall, facing out, upright.
- **Ceilings** and **slopes** are excluded by default; allow them in ``PlacementOptions``.

The content's front is its +Z axis, the USD convention used by Reality Composer Pro.

## Place on a tap

On visionOS, a `SpatialTapGesture` on an entity with a collision shape (for example the
scene-reconstruction mesh) gives the hit point; the device position comes from
`WorldTrackingProvider.queryDeviceAnchor(atTimestamp:)`.

```swift
let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))

func place(_ entity: Entity, at point: SIMD3<Float>, normal: SIMD3<Float>, viewer: SIMD3<Float>) {
    do {
        let placement = try solver.place(on: SurfaceHit(position: point, normal: normal), facing: viewer)
        entity.setPose(placement.pose)
    } catch .surfaceNotAllowed(let surface) {
        showHint("Content cannot go on a \(surface.rawValue).")
    } catch {
        showHint("Try another spot.")
    }
}
```

## Options

| Option                                   | Effect                                                                                          |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------- |
| ``PlacementOptions/gridSize``              | Snaps the position to a grid in the surface plane; the distance to the surface does not change. |
| ``PlacementOptions/rotationStep``          | On floors and ceilings, turns toward the viewer in fixed steps.                                 |
| ``PlacementOptions/surfaceOffset``         | Lifts the content off the surface along the normal.                                             |
| ``PlacementOptions/alignsToSurfaceNormal`` | Tilts content with a floor that is not level instead of keeping it upright.                     |
| ``PlacementOptions/surfaceTolerance``      | How far a normal may lean and still count as floor, ceiling or wall.                            |

Invalid values (a zero grid, a NaN step) turn the option off rather than producing NaN poses.

## Fit a model of unknown size

USDZ files arrive in centimeters or meters and centered anywhere. ``SpatialBounds`` computes the
uniform scale that fits a box into a volume and the offset that rests it on its bottom center:

```swift
let model = try await Entity(named: "Chair")
model.scaleToFit(SIMD3(0.3, 0.3, 0.3))   // never enlarges unless you pass allowsUpscaling: true
```

Without RealityKit, use the bounds directly:

```swift
if let bounds = SpatialBounds(points: vertices) {
    let scale = bounds.scaleToFit(SIMD3(repeating: 0.3))
    let offset = bounds.restingOffset(scale: scale)
}
```
