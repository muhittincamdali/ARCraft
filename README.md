<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="Latest version: v1.1.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

ARCraft is a Swift package for visionOS and iOS apps that use hand tracking and world anchors.
It does not wrap RealityKit: RealityKit already renders, simulates and manipulates entities. It
covers the code that sits between ARKit's raw data and your scene, which each spatial app
otherwise writes on its own: recognizing a pinch without flicker, keeping a fingertip cursor
steady, turning a tap on a table into an upright, snapped pose, and remembering which content
belongs to which world anchor across launches. The core is plain Swift and `simd` with no
dependencies, so it runs and is tested on the Mac, in the simulator and in previews; thin adapters
connect it to ARKit on visionOS, to Vision's hand pose on iOS and macOS, and to RealityKit
entities.

## Highlights

- **Gestures that do not flicker** — `HandGestureRecognizer` adds frame debounce, a wider release
  distance for pinches and cancel-on-tracking-loss on top of a scale-free hand shape classifier
  (pinch, point, fist, open palm) that works in meters (ARKit) and pixels (Vision).
- **Jitter filtering** — `OneEuroFilter` and `PoseFilter` smooth fingertips, wrists and anchors
  hard at rest and lightly in motion, and ignore NaN samples and out-of-order timestamps.
- **Surface placement** — `PlacementSolver` keeps content upright on tables, flat on walls and
  turned toward the viewer, with optional grid and rotation snapping; `SpatialBounds` fits models
  of unknown size into a volume.
- **Content that stays in the room** — `AnchoredItem`, `AnchorResolver` and `PlacementStore`
  record what was placed relative to which `WorldAnchor`, and read the file back as untrusted
  input: size-limited before parsing, versioned, and one damaged entry does not lose the rest.
- **Works without a headset** — `SyntheticHand` builds hand poses for the simulator, previews and
  tests; `HandPose` is `Codable` for recording and replay.
- **Tested** — 103 Swift Testing tests run on macOS and an iPhone simulator (105 on the visionOS
  simulator, including the ARKit adapters), and every README sample below is compiled and run by
  the test target.

### What's included

| Area | Types |
| --- | --- |
| Hands | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| Filtering | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| Placement | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| Persistence | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| Geometry | `Pose` (position and unit quaternion, `Codable`, rejects NaN) |
| Adapters | `HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)` on visionOS; `HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` with Vision |

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/ARCraft.git
```

Paste it into the search field at the top right of the window, set **Dependency Rule** to
**Branch** › `main`, then click **Add Package**. In the next window, choose your app target next
to **ARCraft** and click **Add Package** again.

**2. Import the module**

```swift
import ARCraft
```

Put this line at the top of the Swift file where you use ARCraft.

**3. Use it**

Add this function to any Swift file in your app (or a unit test) and call
`print(pinchDemo())`. It closes and opens a synthetic hand at 90 frames per second, so it runs
on any device and in the simulator:

```swift
func pinchDemo() -> [String] {
    var pinch = HandGestureRecognizer(configuration: .init(shape: .pinch))
    var log: [String] = []
    let closing: [Float] = [0, 0.3, 0.6, 0.9, 1, 1, 1, 0.6, 0.3, 0.1, 0]
    for (frame, amount) in closing.enumerated() {
        let pose = SyntheticHand.openPalm
            .interpolated(to: .pinch, fraction: amount)
            .pose(timestamp: Double(frame) / 90)
        for event in pinch.update(with: pose) {
            switch event {
            case .began: log.append("pinch began at frame \(frame)")
            case .ended: log.append("pinch ended at frame \(frame)")
            case .changed, .cancelled: break
            }
        }
    }
    return log
}
```

It prints `["pinch began at frame 4", "pinch ended at frame 9"]`. The pinch begins on the second
closed frame and ends after three frames open past the release distance, which is what keeps it
from flickering. On Apple Vision Pro you feed the same recognizer with `HandPose(update.anchor,
timestamp: update.timestamp)`, as shown under [Usage](#usage).

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/ARCraft.git
```

In a `Package.swift` manifest, add the package and the product:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/ARCraft.git", from: "1.1.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "ARCraft", package: "ARCraft")
    ])
]
```

The API described here ships in 1.1.0, the first release with library sources. The earlier tag
`v1.0.0` contains none (see the [changelog](CHANGELOG.md)).

## Usage

Every sample below is copied from the [example app](Examples/ARCraftLab), which CI builds for
iOS, macOS and visionOS.

### Recognize pinches on Apple Vision Pro

From [`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift), which runs
inside an `ImmersiveSpace` with `NSHandsTrackingUsageDescription` in the Info.plist:

```swift
private func processHands() async {
    for await update in handTracking.anchorUpdates where update.anchor.chirality == .right {
        guard let pose = HandPose(update.anchor, timestamp: update.timestamp) else {
            if pinch.trackingLost(at: update.timestamp) == .cancelled { isPinching = false }
            fingertip = nil
            fingertipFilter.reset()
            continue
        }
        fingertip = pose[.indexFingerTip].flatMap { fingertipFilter.filter($0, at: update.timestamp) }
        for event in pinch.update(with: pose) {
            await handle(event)
        }
    }
}
```

`pinch` is a `HandGestureRecognizer(configuration: .init(shape: .pinch))`; when the hand is lost
for longer than the tolerance, the gesture is cancelled instead of ended, so a hand leaving the
field of view never places anything.

### Smooth a fingertip

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### Place content on a table

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

The content stands upright at `(0.40, 0.74, -0.80)`, turned toward the viewer in a 45° step. Its
front is its +Z axis, the USD convention. On a wall it would lie flat against the wall, facing out.

### Fit a model of unknown size

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

Returns `0.0025`: a model authored 120 units wide becomes 30 cm wide. On a RealityKit entity, call
`entity.scaleToFit(SIMD3(repeating: 0.3))` instead.

### Save placed content and restore it

```swift
func saveAndRestore(in folder: URL) async throws -> [ItemStatus] {
    let store = PlacementStore(fileURL: folder.appendingPathComponent("room.json"))
    let anchor = WorldAnchorState(id: UUID(), pose: Pose(position: SIMD3(0, 0.8, -1)))
    let lamp = AnchoredItem(kind: "lamp", worldPose: Pose(position: SIMD3(0.2, 0.8, -1.1)), anchor: anchor)
    try await store.save([lamp])

    // Next launch: ARKit reports the anchor again and the store returns the items.
    var resolver = AnchorResolver()
    resolver.update(anchor)
    let restored = try await store.load().items
    return restored.map { resolver.status(of: $0) }
}
```

On visionOS the anchor comes from `WorldTrackingProvider`. The live space attaches new content to
a tracked anchor within 50 cm, or creates one:

```swift
private func place(kind: String, at worldPose: Pose) async {
    let anchor: WorldAnchorState
    if let nearby = resolver.nearestTrackedAnchor(to: worldPose.position, within: 0.5) {
        anchor = nearby
    } else {
        let worldAnchor = WorldAnchor(originFromAnchorTransform: worldPose.matrix)
        do {
            try await worldTracking.addAnchor(worldAnchor)
        } catch {
            status = .failed(error.localizedDescription)
            return
        }
        guard let state = WorldAnchorState(worldAnchor) else { return }
        resolver.update(state)
        anchor = state
    }
    items.append(AnchoredItem(kind: kind, worldPose: worldPose, anchor: anchor))
    do {
        try await store?.save(items)
    } catch {
        status = .failed(error.localizedDescription)
    }
}
```

## Demo

Screens of the [example app](Examples/ARCraftLab), captured from the iOS simulator by
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). Each runs ARCraft on
synthetic or recorded data.

| Hand gestures | Smoothing | Placement | Persistence |
| --- | --- | --- | --- |
| ![Hand gestures, light](docs/images/gestures-light.png) | ![Smoothing, light](docs/images/smoothing-light.png) | ![Placement, light](docs/images/placement-light.png) | ![Persistence, light](docs/images/persistence-light.png) |
| ![Hand gestures, dark](docs/images/gestures-dark.png) | ![Smoothing, dark](docs/images/smoothing-dark.png) | ![Placement, dark](docs/images/placement-dark.png) | ![Persistence, dark](docs/images/persistence-dark.png) |

## Documentation

- [API reference](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) (DocC, published to GitHub Pages from `main`)
- Build it locally in Xcode with **Product › Build Documentation**, or from the command line:

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## Guides

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted)
  — add the package, recognize a pinch on synthetic data, then on ARKit data
  ([source](Sources/ARCraft/ARCraft.docc/GettingStarted.md)).
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures)
  — how shapes are measured, debounce, hysteresis, tracking loss, two hands and Vision on iOS
  ([source](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md)).
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata)
  — tuning the One Euro filter and smoothing poses
  ([source](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md)).
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces)
  — floors, walls, snapping and fitting models
  ([source](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md)).
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent)
  — world anchors, restoring on launch, cleaning up, and the file format's limits
  ([source](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md)).
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset)
  — synthetic and recorded hands, and anchors in unit tests
  ([source](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md)).

## Requirements

| Platform | Minimum version |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| Toolchain | Swift 6.2 · Xcode 26+ |

Hand and world tracking need Apple Vision Pro; the ARKit adapters compile for visionOS only. CI
builds with the default Xcode of GitHub's `macos-26` runner image. The package is developed with
Xcode 27 against the iOS 27 and visionOS 27 SDKs.

## When to use something else

- **Moving, rotating and scaling entities with the standard gestures:** RealityKit's
  `ManipulationComponent` (visionOS 26) and `GestureComponent` do this without extra code.
- **Matching custom static hand poses by similarity:**
  [HandVector](https://github.com/XanderXu/HandVector) compares whole-hand joint vectors against
  recorded templates; ARCraft classifies four fixed shapes with explicit thresholds.
- **Semantic gestures as SwiftUI modifiers (clap, snap, punch):**
  [HandGesture](https://github.com/johnhaney/HandGesture).
- **3D UI controls (switches, sliders, buttons as entities):**
  [RealityUI](https://github.com/maxxfrazer/RealityUI).

## Architecture

- `Sources/ARCraft/Math`, `Filtering`, `Hands`, `Placement` and `Persistence` are value types
  that use only Foundation and `simd`. `PlacementStore` is the only reference type (an actor that
  serializes file access).
- `Sources/ARCraft/Platform` holds the adapters: `ARKit+ARCraft.swift` (visionOS only) and
  `Vision+ARCraft.swift`. `Placement/Entity+ARCraft.swift` adds the RealityKit helpers.
- Every type that accepts outside input validates it at the boundary: matrices and decoded
  numbers must be finite, configuration values are clamped, collections and files have size
  limits, and file names cannot leave the app's folder.
- Tests live in `Tests/ARCraftTests` (Swift Testing). The hand classifier is tested against
  hand-typed joint fixtures as well as synthetic hands, so the two do not only agree with each
  other.

Run the tests locally:

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Roadmap

- Tag the 2.0.0 release and add the package to the Swift Package Index; `.spi.yml` is already in
  the repository.
- Two-hand gestures (scale and rotate between both pinches) on top of `HandGestureRecognizer`.
- Placement on plane anchors' extents, so content is kept inside a detected table's edges.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
