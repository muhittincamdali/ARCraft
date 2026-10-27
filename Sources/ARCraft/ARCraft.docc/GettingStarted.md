# Getting Started

Add the package, recognize a pinch, and see the result without a headset.

## Add the package

In Xcode choose **File > Add Package Dependencies…**, paste
`https://github.com/muhittincamdali/ARCraft.git` into the search field, choose **Add Package**,
and add the **ARCraft** library to your app target. In a package, add it to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/ARCraft.git", branch: "main")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "ARCraft", package: "ARCraft")
    ])
]
```

ARCraft needs Swift 6.2 tools (Xcode 26 or later) and runs on iOS 18, macOS 15 and visionOS 2 or
later. It has no dependencies.

## Recognize a pinch

A ``HandGestureRecognizer`` takes one ``HandPose`` per frame and returns events. This loop uses
``SyntheticHand`` to close and open a hand, so it runs anywhere:

```swift
import ARCraft

var pinch = HandGestureRecognizer(configuration: .init(shape: .pinch))
let closing: [Float] = [0, 0.3, 0.6, 0.9, 1, 1, 1, 0.6, 0.3, 0.1, 0]
for (frame, amount) in closing.enumerated() {
    let pose = SyntheticHand.openPalm
        .interpolated(to: .pinch, fraction: amount)
        .pose(timestamp: Double(frame) / 90)
    for event in pinch.update(with: pose) {
        print(frame, event)
    }
}
// began at frame 4, ended at frame 9
```

The pinch begins at frame 4, not 3: by default a shape must match for two frames in a row. It
ends at frame 9: once begun, a pinch lasts until the fingers open past a wider release distance
for three frames. Both keep the gesture from flickering when the measurement sits on a threshold.

## Use real tracking data

On Apple Vision Pro, create the pose from ARKit's `HandAnchor` inside an immersive space:

```swift
let session = ARKitSession()
let handTracking = HandTrackingProvider()
try await session.run([handTracking])

for await update in handTracking.anchorUpdates {
    guard let pose = HandPose(update.anchor, timestamp: update.timestamp) else {
        _ = pinch.trackingLost(at: update.timestamp)
        continue
    }
    for event in pinch.update(with: pose) { handle(event) }
}
```

Add `NSHandsTrackingUsageDescription` to your Info.plist. On iOS, create the pose from Vision's
`HumanHandPoseObservation` with ``HandPose/init(_:imageSize:timestamp:minimumConfidence:)``.

## Next steps

- <doc:RecognizingHandGestures> covers the other shapes and the recognizer's settings.
- <doc:PlacingContentOnSurfaces> turns a tap on a table or wall into a pose.
- <doc:PersistingPlacedContent> keeps placed content in the room across launches.
- The `Examples/ARCraftLab` app in the repository runs every part on synthetic data.
