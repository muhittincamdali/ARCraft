# Testing Without a Headset

Drive gesture, placement and persistence code from unit tests, previews and the simulator.

## Overview

Hand tracking does not run in the visionOS simulator, in Xcode previews or in unit tests, and
world anchors behave differently there. Because ARCraft's types are values that do not depend on
ARKit, you can feed them data from anywhere.

## Synthetic hands

``SyntheticHand`` builds a plausible ``HandPose`` from finger curl amounts. Use a preset, or blend
between two to animate:

```swift
let fist = SyntheticHand.fist.pose(chirality: .left, palmLength: 0.08)
let halfClosed = SyntheticHand.openPalm.interpolated(to: .pinch, fraction: 0.5).pose(timestamp: 0.5)
```

In a test, step through frames and check the events:

```swift
@Test func pinchDragsTheSelection() {
    var model = DragModel()
    for frame in 0..<10 {
        let amount: Float = frame < 6 ? 1 : 0
        model.handle(SyntheticHand.openPalm.interpolated(to: .pinch, fraction: amount)
            .pose(timestamp: Double(frame) / 90))
    }
    #expect(model.drops == 1)
}
```

## Recorded hands

``HandPose`` is `Codable`. Record poses on a device and replay them in tests or the simulator:

```swift
let recording = try JSONEncoder().encode(poses)          // on Apple Vision Pro
let replay = try JSONDecoder().decode([HandPose].self, from: recording)
```

Decoding skips joint names it does not know and throws for malformed coordinates. Recordings can
hold hand geometry of real people; keep them out of logs and analytics, and limit the size of
files you read back.

## Anchors

``AnchorResolver`` takes ``WorldAnchorState`` values, which you can create directly:

```swift
var resolver = AnchorResolver()
resolver.update(WorldAnchorState(id: anchorID, pose: Pose(position: [0, 0.8, -1]), isTracked: false))
#expect(resolver.status(of: lamp) == .anchorNotTracked(lastKnown: expectedPose))
```

The `ARCraftLab` example app uses the same techniques for each of its screens.
