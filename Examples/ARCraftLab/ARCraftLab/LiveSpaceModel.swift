#if os(visionOS)
import ARCraft
import ARKit
import Foundation
import Observation

/// Runs hand and world tracking on Apple Vision Pro: a filtered fingertip cursor, pinch-to-place
/// cubes, and cubes that stay anchored to the room across launches.
@MainActor
@Observable
final class LiveSpaceModel {
    enum Status: Equatable {
        case idle
        case running
        case unavailable(String)
        case failed(String)
    }

    private(set) var status: Status = .idle
    private(set) var isPinching = false
    private(set) var fingertip: SIMD3<Float>?
    private(set) var items: [AnchoredItem] = []
    private(set) var resolver = AnchorResolver()

    @ObservationIgnored private let session = ARKitSession()
    @ObservationIgnored private let handTracking = HandTrackingProvider()
    @ObservationIgnored private let worldTracking = WorldTrackingProvider()
    @ObservationIgnored private var pinch = HandGestureRecognizer(configuration: .init(shape: .pinch))
    @ObservationIgnored private var fingertipFilter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    @ObservationIgnored private let store: PlacementStore?

    init() {
        store = try? PlacementStore(fileURL: PlacementStore.applicationSupportFile(named: "lab-room.json"))
    }

    /// Starts tracking and processes updates until the task is cancelled.
    func run() async {
        guard HandTrackingProvider.isSupported, WorldTrackingProvider.isSupported else {
            status = .unavailable("Hand and world tracking need Apple Vision Pro; the simulator does not provide them.")
            return
        }
        do {
            items = try await store?.load().items ?? []
            try await session.run([handTracking, worldTracking])
            status = .running
        } catch {
            status = .failed(error.localizedDescription)
            return
        }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.processHands() }
            group.addTask { await self.processWorldAnchors() }
        }
    }

    /// Removes every cube and its anchors.
    func clear() async {
        for anchorID in Set(items.map(\.anchorID)) {
            try? await worldTracking.removeAnchor(forID: anchorID)
        }
        items = []
        try? await store?.removeAll()
    }

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

    private func handle(_ event: HandGestureEvent) async {
        switch event {
        case .began:
            isPinching = true
        case .changed:
            break
        case .ended(let release):
            isPinching = false
            if let tip = release[.indexFingerTip] {
                await place(kind: "cube", at: Pose(position: tip))
            }
        case .cancelled:
            isPinching = false
        }
    }

    private func processWorldAnchors() async {
        for await update in worldTracking.anchorUpdates {
            resolver.apply(update)
        }
    }

    /// Attaches a new cube to a tracked anchor within 50 cm, or to a new anchor, and saves.
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
}
#endif
