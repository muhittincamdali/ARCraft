# Examples

## ARCraftLab

A small app for iOS, macOS and visionOS that runs ARCraft on synthetic and recorded data, so every
screen works in the simulator and on the Mac:

- **Hand gestures** — a synthetic hand you can close into a pinch, the classifier's measurements,
  and a recorded pinch replayed through `HandGestureRecognizer`.
- **Smoothing** — a jittery fingertip track before and after `OneEuroFilter`, with the filter's
  two settings on sliders.
- **Placement** — a room seen from above; tap the floor or the wall and `PlacementSolver` places an
  object turned toward you, with grid and rotation snapping.
- **Persistence** — four items on three world anchors saved with `PlacementArchive`, read back
  (optionally from a damaged file) and resolved with `AnchorResolver`.

On Apple Vision Pro the visionOS build adds a **live space**
([`LiveSpaceModel.swift`](ARCraftLab/ARCraftLab/LiveSpaceModel.swift)): a cursor on your right
index fingertip, smoothed with `OneEuroFilter`; a cube placed wherever a pinch ends; and the
cubes anchored with `WorldAnchor` and saved with `PlacementStore`, so they are still there on the
next launch. The simulator has no hand tracking, so there the live space says so instead.

Run it:

1. Open `Examples/ARCraftLab/ARCraftLab.xcodeproj` in Xcode 26 or later.
2. Choose the **ARCraftLab** scheme and an iPhone simulator, the Apple Vision Pro simulator or
   **My Mac** as the run destination.
3. Press **Run** (⌘R).

From the command line:

```sh
cd Examples/ARCraftLab
xcodebuild build -scheme ARCraftLab -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme ARCraftLab -destination 'generic/platform=visionOS Simulator'
xcodebuild build -scheme ARCraftLab -destination 'platform=macOS'
```

The README samples live in
[`ARCraftLab/ReadmeSamples.swift`](ARCraftLab/ARCraftLab/ReadmeSamples.swift). The README copies
its code from that file, and the package's test target compiles and runs the same file through
the symlink `Tests/ARCraftTests/ReadmeExamples.swift`.

The screenshots in the README come from this app:
[`scripts/capture-example-screens.sh`](../scripts/capture-example-screens.sh) builds it, opens
each screen with `-screen <name>` on an iPhone simulator and saves light and dark images to
`docs/images/`.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](ARCraftLab/project.yml) and committed, so you only need XcodeGen after editing
`project.yml`.
