# Persisting Placed Content

Keep the content people place in a room there across launches, using world anchors.

## Overview

On visionOS, a `WorldAnchor` you add to a `WorldTrackingProvider` is persisted by the system and
reported again on later launches once the device recognizes the room. What your app attached to
the anchor is not. ARCraft adds that record and its bookkeeping:

- ``AnchoredItem`` stores the anchor's identifier, what to show, and the item's offset from the
  anchor. Several items can share one anchor.
- ``AnchorResolver`` keeps the latest state of each anchor and tells you where each item is now.
- ``PlacementStore`` saves the items to a JSON file through ``PlacementArchive``.

Add `NSWorldSensingUsageDescription` to your Info.plist.

## Place and save

Attach new content to a tracked anchor nearby when there is one; Apple recommends using few world
anchors.

```swift
let worldTracking = WorldTrackingProvider()
var resolver = AnchorResolver()
let store = try PlacementStore(fileURL: PlacementStore.applicationSupportFile(named: "room.json"))
var items = try await store.load().items

func place(kind: String, at worldPose: Pose) async throws {
    let anchor: WorldAnchorState
    if let nearby = resolver.nearestTrackedAnchor(to: worldPose.position, within: 0.5) {
        anchor = nearby
    } else {
        let worldAnchor = WorldAnchor(originFromAnchorTransform: worldPose.matrix)
        try await worldTracking.addAnchor(worldAnchor)
        guard let state = WorldAnchorState(worldAnchor) else { return }
        resolver.update(state)
        anchor = state
    }
    items.append(AnchoredItem(kind: kind, worldPose: worldPose, anchor: anchor))
    try await store.save(items)
}
```

## Restore

Feed every anchor update to the resolver and show each item according to its ``ItemStatus``:

```swift
for await update in worldTracking.anchorUpdates {
    resolver.apply(update)
    for item in items {
        switch resolver.status(of: item) {
        case .placed(let pose): show(item, at: pose)
        case .anchorNotTracked: hide(item)        // in another room, or not relocalized yet
        case .anchorMissing: hide(item)           // not reported (yet) in this session
        }
    }
}
```

An anchor can take a while to be reported after launch, so do not delete items whose anchor is
missing right away. To clean up, remove anchors that no item uses:

```swift
for id in resolver.unusedAnchorIDs(given: items) {
    try await worldTracking.removeAnchor(forID: id)
}
```

## The file

``PlacementArchive`` treats the file as untrusted input:

- The size is checked before parsing (1 MiB by default), and ``PlacementStore`` never reads more
  than that, even if the file grows while it is read.
- An archive from a newer format version is refused with
  ``PlacementArchiveError/unsupportedVersion(_:)``.
- Each item is decoded on its own. A damaged item, one over a limit, or a repeated identifier is
  skipped and counted in ``PlacementArchive/Contents/rejectedCount``; the others load.
- Writing is strict: an item that could not be read back throws instead of being saved, and a
  failed save leaves the previous file untouched.

``PlacementStore/applicationSupportFile(named:)`` accepts plain file names only, so a name built
from user input cannot point outside the app's folder.
