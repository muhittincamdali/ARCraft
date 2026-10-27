# Smoothing Tracking Data

Remove tracking jitter without making fast movements lag.

## Overview

Joint and anchor positions tremble by a few millimeters from frame to frame. A cursor drawn at the
raw fingertip shimmers; a fixed low-pass filter that hides the shimmer makes quick moves trail
behind. ``OneEuroFilter`` adapts: it smooths hard while the value is still and lightly while it
moves fast.

```swift
var fingertipFilter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)

if let tip = pose[.indexFingerTip], let smoothed = fingertipFilter.filter(tip, at: pose.timestamp) {
    cursor.position = smoothed
}
```

## Tuning

``OneEuroConfiguration`` has two settings that matter:

- ``OneEuroConfiguration/minimumCutoff`` (hertz) sets how much jitter is removed at rest. Lower
  is smoother and slower.
- ``OneEuroConfiguration/speedCoefficient`` sets how quickly smoothing drops as speed rises.
  Higher means less lag on fast moves.

Start with a preset — ``OneEuroConfiguration/handJoints`` for fingertips and wrists,
``OneEuroConfiguration/anchors`` for anchors and head position — then lower `minimumCutoff` until
the value is steady at rest and raise `speedCoefficient` until fast moves stop lagging. The
Smoothing screen of the `ARCraftLab` example app shows both effects on a recorded track.

## Poses

``PoseFilter`` smooths a ``Pose``: the position through a One Euro filter and the orientation
with the same speed rule applied through spherical interpolation. Use it for content that follows
a tracked transform, such as a menu attached to the wrist:

```swift
var wristFilter = PoseFilter(position: .handJoints, orientation: .handJoints)

if let wrist = Pose(matrix: wristTransform), let smoothed = wristFilter.filter(wrist, at: timestamp) {
    palmMenu.setPose(smoothed)
}
```

## Bad input

Both filters ignore NaN and infinite samples, repeated timestamps and timestamps that go
backwards, returning the previous output instead. After a gap longer than
``OneEuroConfiguration/resetInterval`` they restart, so a hand that reappears elsewhere jumps
there instead of gliding across the room.
