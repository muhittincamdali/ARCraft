# Recognizing Hand Gestures

Classify pinch, point, fist and open-palm shapes and turn them into stable began, changed and
ended events.

## Overview

ARKit and Vision report joint positions, not gestures. ARCraft splits the job in two:

- ``HandShapeClassifier`` looks at one frame and returns a ``HandShapeReading``: the shape, the
  normalized thumb-to-index distance and how far each finger is extended.
- ``HandGestureRecognizer`` watches a sequence of frames for one shape and emits
  ``HandGestureEvent`` values.

## How shapes are measured

Every measure is a ratio of two distances on the same hand, so it does not depend on hand size,
on the unit (meters from ARKit, pixels from Vision) or on where the hand is:

- **Palm length** is the distance from the wrist to the middle knuckle (or the index knuckle).
- **Pinch distance** is thumb tip to index tip divided by the palm length: about 0.1 while
  pinching, 0.8 or more with the hand open.
- **Finger extension** is wrist-to-tip divided by wrist-to-knuckle: about 1.8 for a straight
  finger, below 1 for a curled one.

A pinch also needs the index finger not to be curled, so a fist whose thumb rests on the index
fingertip stays a fist. Tune the thresholds with ``HandShapeClassifier/Configuration``.

```swift
let reading = HandShapeClassifier().classify(pose)
if reading.shape == .point, let tip = pose[.indexFingerTip] {
    laserPointer.position = tip
}
```

## Events without flicker

```swift
var grab = HandGestureRecognizer(configuration: .init(shape: .fist, framesToBegin: 3, framesToEnd: 4))

for event in grab.update(with: pose) {
    switch event {
    case .began(let pose): pickUp(at: pose[.wrist])
    case .changed(let pose): move(to: pose[.wrist])
    case .ended(let pose): drop(at: pose[.wrist])
    case .cancelled: putBack()
    }
}
```

- `framesToBegin` and `framesToEnd` debounce the start and the end.
- For pinches, ``HandGestureRecognizer/Configuration/pinchReleaseDistance`` is wider than the
  distance that starts a pinch. A pinch that relaxes slightly while dragging keeps going.
- ``HandGestureEvent/ended(_:)`` carries the last frame that still matched, which is where the
  user actually let go.
- When frames stop arriving for longer than `trackingLossTolerance`, the next frame (or a call to
  ``HandGestureRecognizer/trackingLost(at:)``) produces ``HandGestureEvent/cancelled``, not
  `ended`: a hand that left the field of view did not release anything.
- Frames whose timestamp does not move forward are ignored.

## Two hands

Use one recognizer per hand and route updates by ``HandPose/chirality``:

```swift
var leftPinch = HandGestureRecognizer(configuration: .init(shape: .pinch))
var rightPinch = HandGestureRecognizer(configuration: .init(shape: .pinch))

let events = pose.chirality == .left ? leftPinch.update(with: pose) : rightPinch.update(with: pose)
```

## Camera hand pose on iOS

Vision's `DetectHumanHandPoseRequest` returns 2D joints. Pass the image size so distances are
measured in pixels on both axes:

```swift
let observations = try await DetectHumanHandPoseRequest().perform(on: pixelBuffer)
for observation in observations {
    guard let pose = HandPose(observation, imageSize: CGSize(width: 1920, height: 1080),
                              timestamp: frameTime) else { continue }
    for event in pinch.update(with: pose) { handle(event) }
}
```

2D poses are reliable when the palm faces the camera; a hand seen edge-on foreshortens the
fingers and reads as curled.
