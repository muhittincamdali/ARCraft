# ``ARCraft``

Tested building blocks for spatial apps on visionOS and iOS: hand gesture recognition, jitter
filtering, surface placement and world anchor persistence.

## Overview

RealityKit draws and simulates your scene, and ARKit reports hands, planes and anchors. Between
the two sits code that every spatial app writes again: deciding that a hand is pinching without
flicker, keeping a fingertip cursor steady, turning a tap on a table into an upright, snapped
pose, and remembering which content belongs to which world anchor across launches. ARCraft is
that code, as plain value types with unit tests.

The core is platform-neutral Swift and `simd`, so it runs in `swift test` on the Mac, in the
simulator and in previews. Thin adapters connect it to ARKit on visionOS (`HandAnchor`,
`WorldAnchor`), to Vision's 2D hand pose on iOS and macOS, and to RealityKit entities.

```swift
import ARCraft

var pinch = HandGestureRecognizer(configuration: .init(shape: .pinch))

for await update in handTracking.anchorUpdates {
    guard let pose = HandPose(update.anchor, timestamp: update.timestamp) else { continue }
    for case .ended(let release) in pinch.update(with: pose) {
        if let tip = release[.indexFingerTip] { placeCube(at: tip) }
    }
}
```

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:RecognizingHandGestures>
- <doc:SmoothingTrackingData>
- <doc:PlacingContentOnSurfaces>
- <doc:PersistingPlacedContent>
- <doc:TestingWithoutAHeadset>

### Hands

- ``HandPose``
- ``HandJoint``
- ``Finger``
- ``HandShape``
- ``HandShapeClassifier``
- ``HandShapeReading``
- ``HandGestureRecognizer``
- ``HandGestureEvent``
- ``SyntheticHand``

### Filtering

- ``OneEuroFilter``
- ``OneEuroConfiguration``
- ``PoseFilter``

### Placement

- ``PlacementSolver``
- ``PlacementOptions``
- ``Placement``
- ``PlacementError``
- ``SurfaceHit``
- ``SurfaceOrientation``
- ``SpatialBounds``

### Persistence

- ``AnchoredItem``
- ``WorldAnchorState``
- ``AnchorResolver``
- ``ItemStatus``
- ``PlacementArchive``
- ``PlacementArchiveError``
- ``PlacementStore``
- ``PlacementStoreError``

### Geometry

- ``Pose``
