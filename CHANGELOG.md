# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-10-28

ARCraft is rebuilt around the parts of spatial apps that RealityKit and ARKit leave to the app.
The SwiftUI-style RealityKit wrapper added after 1.0.0 and the placeholder actors that replaced
it in June 2026 are removed; RealityKit's own APIs cover what the wrapper did.

### Added

- `HandPose`, `HandJoint` and `Finger`: tracked joints in one coordinate space, `Codable` for
  recording and replay, with non-finite joints dropped.
- `HandShapeClassifier`: scale-free pinch, point, fist and open-palm classification that works on
  ARKit (meters) and Vision (pixels) data.
- `HandGestureRecognizer`: began, changed, ended and cancelled events with frame debounce, pinch
  hysteresis and cancel-on-tracking-loss.
- `SyntheticHand`: plausible hand poses from finger curl amounts, for the simulator, previews and
  tests.
- `OneEuroFilter` and `PoseFilter`: speed-adaptive smoothing for positions and poses that ignores
  NaN samples and out-of-order timestamps.
- `PlacementSolver`, `PlacementOptions`, `SurfaceHit` and `SurfaceOrientation`: upright,
  viewer-facing placement on floors, flat placement on walls, grid and rotation snapping.
- `SpatialBounds` and `Entity.scaleToFit(_:allowsUpscaling:)`: fit models of unknown size into a
  volume; `Entity.setPose(_:relativeTo:)` and `Entity.pose(relativeTo:)`.
- `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `PlacementArchive` and `PlacementStore`:
  content stored relative to world anchors, a size-limited, versioned JSON archive that skips
  damaged entries, and atomic, file-protected storage under Application Support.
- `Pose`: a position and unit quaternion that rejects NaN, mirrored and degenerate matrices.
- Adapters for ARKit `HandAnchor` and `WorldAnchor` updates on visionOS and for Vision's
  `HumanHandPoseObservation`.
- DocC catalog with six guides, the ARCraftLab example app for iOS, macOS and visionOS, and a
  script that captures the README screenshots from it.

### Changed

- Minimum platforms are iOS 18, macOS 15 and visionOS 2, with Swift tools 6.2 and the Swift 6
  language mode.
- CI uses the shared workflows of muhittincamdali/.github: SwiftPM build and test, xcodebuild for
  iOS, macOS and visionOS, tests on an iOS simulator, DocC on GitHub Pages, link and wording
  checks, and an example app build.

### Removed

- The declarative wrapper types (`Model`, `Box` and the session, anchor, entity, material,
  gesture and physics wrappers) and the placeholder actors `VisionPhysicsEngine`,
  `SpatialMeshNetwork` and `HandTrackingController`.
- The CocoaPods podspec, which pointed at sources that no longer exist.

## [1.0.0] - 2026-02-03

### Added

- Package manifest, MIT license and a CI workflow. The tag contains no library sources.

[Unreleased]: https://github.com/muhittincamdali/ARCraft/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/muhittincamdali/ARCraft/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/muhittincamdali/ARCraft/releases/tag/v1.0.0
