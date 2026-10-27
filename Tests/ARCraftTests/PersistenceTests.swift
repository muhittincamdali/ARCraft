import Foundation
import Testing
import simd
@testable import ARCraft

private let anchorID = UUID(uuidString: "6F9619FF-8B86-D011-B42D-00C04FC964FF")!

private func item(_ kind: String = "lamp", id: UUID = UUID(), x: Float = 0) -> AnchoredItem {
    AnchoredItem(id: id, anchorID: anchorID, kind: kind, offset: Pose(position: SIMD3(x, 0, 0)))
}

@Suite("PlacementArchive")
struct PlacementArchiveTests {
    private let archive = PlacementArchive()

    @Test("Items round-trip in order")
    func roundTrip() throws {
        let items = [item("lamp", x: 0.1), item("plant", x: -0.4), AnchoredItem(anchorID: anchorID, kind: "note", attributes: ["text": "Hi"])]
        let contents = try archive.decode(archive.encode(items))
        #expect(contents.items == items)
        #expect(contents.rejectedCount == 0)
    }

    @Test("Writing refuses items that could not be read back")
    func strictEncoding() {
        let tooLongKind = item(String(repeating: "k", count: 129))
        let nanOffset = AnchoredItem(anchorID: anchorID, kind: "x", offset: Pose(position: SIMD3(.nan, 0, 0)))
        let emptyKey = AnchoredItem(anchorID: anchorID, kind: "x", attributes: ["": "v"])
        for invalid in [item(""), tooLongKind, nanOffset, emptyKey] {
            #expect(throws: PlacementArchiveError.invalidItem(id: invalid.id)) { try archive.encode([invalid]) }
        }
        let duplicate = item()
        #expect(throws: PlacementArchiveError.duplicateItem(id: duplicate.id)) { try archive.encode([duplicate, duplicate]) }
    }

    @Test("Writing respects the item and byte limits")
    func encodingLimits() {
        let small = PlacementArchive(limits: .init(maxBytes: 200, maxItems: 2))
        #expect(throws: PlacementArchiveError.tooManyItems(count: 3, limit: 2)) { try small.encode([item(), item(), item()]) }
        #expect(throws: PlacementArchiveError.self) { try small.encode([item(), item()]) }
    }

    @Test("Damaged items are skipped and counted; valid ones survive")
    func lenientDecoding() throws {
        let good = item("lamp")
        let goodJSON = String(decoding: try JSONEncoder().encode(good), as: UTF8.self)
        let json = """
        {"version":1,"items":[
          \(goodJSON),
          {"id":"not-a-uuid","anchorID":"\(anchorID)","kind":"x","offset":{"position":[0,0,0],"orientation":[0,0,0,1]},"attributes":{}},
          {"id":"\(UUID())","anchorID":"\(anchorID)","kind":"x","offset":{"position":[0,0,0],"orientation":[0,0,0,0]},"attributes":{}},
          {"id":"\(UUID())","anchorID":"\(anchorID)","kind":"","offset":{"position":[0,0,0],"orientation":[0,0,0,1]},"attributes":{}},
          42,
          \(goodJSON)
        ]}
        """
        let contents = try archive.decode(Data(json.utf8))
        #expect(contents.items == [good])
        #expect(contents.rejectedCount == 5)
    }

    @Test("Archives that are not ours, or from a newer version, throw", arguments: [
        ("", PlacementArchiveError.malformed),
        ("[]", .malformed),
        (#"{"items":[]}"#, .malformed),
        (#"{"version":"1","items":[]}"#, .malformed),
        (#"{"version":1}"#, .malformed),
        (#"{"version":1,"items":{}}"#, .malformed),
        (#"{"version":2,"items":[]}"#, .unsupportedVersion(2))
    ])
    func rejectsForeignData(json: String, expected: PlacementArchiveError) {
        #expect(throws: expected) { try archive.decode(Data(json.utf8)) }
    }

    @Test("Oversized data is refused before it is parsed")
    func oversized() {
        let small = PlacementArchive(limits: .init(maxBytes: 64))
        let data = Data(repeating: UInt8(ascii: " "), count: 65)
        #expect(throws: PlacementArchiveError.tooLarge(byteCount: 65, limit: 64)) { try small.decode(data) }
    }

    @Test("Too many items in a file is an error, not a truncation")
    func tooManyOnRead() throws {
        let data = try PlacementArchive().encode([item(), item(), item()])
        #expect(throws: PlacementArchiveError.tooManyItems(count: 3, limit: 2)) {
            try PlacementArchive(limits: .init(maxItems: 2)).decode(data)
        }
    }

    @Test("Limits are kept within a sane range")
    func limitClamps() {
        let limits = PlacementArchive.Limits(maxBytes: .max, maxItems: -5, maxKindLength: 0, maxAttributes: -1,
                                             maxAttributeLength: 0, maxOffsetDistance: -3)
        #expect(limits.maxBytes == PlacementArchive.Limits.maxBytesCeiling)
        #expect(limits.maxItems == 1)
        #expect(limits.maxKindLength == 1)
        #expect(limits.maxAttributes == 1)
        #expect(limits.maxAttributeLength == 1)
        #expect(limits.maxOffsetDistance == 1)
        #expect(PlacementArchive.Limits(maxOffsetDistance: .infinity).maxOffsetDistance == PlacementArchive.Limits.maxOffsetDistanceCeiling)
        #expect(PlacementArchive.Limits(maxOffsetDistance: .nan).maxOffsetDistance == PlacementArchive.Limits.defaultMaxOffsetDistance)
    }

    @Test("Offsets farther than maxOffsetDistance are skipped on read and refused on write")
    func farOffsets() throws {
        let json = """
        {"version":1,"items":[{"id":"\(UUID())","anchorID":"\(anchorID)","kind":"lamp",
          "offset":{"position":[3e38,3e38,3e38],"orientation":[0,0,0,1]},"attributes":{}}]}
        """
        let contents = try archive.decode(Data(json.utf8))
        #expect(contents.items.isEmpty)
        #expect(contents.rejectedCount == 1)
        let far = item(x: 10_001)
        #expect(throws: PlacementArchiveError.invalidItem(id: far.id)) { try archive.encode([far]) }
        #expect(archive.isValid(item(x: 10_000)))
    }

    @Test("Attribute limits are measured in UTF-8 bytes")
    func utf8Limits() {
        let codec = PlacementArchive(limits: .init(maxAttributeLength: 4))
        #expect(codec.isValid(AnchoredItem(anchorID: anchorID, kind: "x", attributes: ["k": "abcd"])))
        #expect(!codec.isValid(AnchoredItem(anchorID: anchorID, kind: "x", attributes: ["k": "çç√"])))
    }
}

@Suite("AnchorResolver")
struct AnchorResolverTests {
    private let anchorPose = Pose(position: SIMD3(1, 0, -2), orientation: simd_quatf(angle: .pi / 2, axis: SIMD3(0, 1, 0)))

    @Test("A tracked anchor places its items; offsets are applied in anchor space")
    func placesItems() throws {
        var resolver = AnchorResolver()
        resolver.update(WorldAnchorState(id: anchorID, pose: anchorPose))
        guard case .placed(let pose) = resolver.status(of: item(x: 0.5)) else {
            Issue.record("Expected a placed item")
            return
        }
        // A quarter turn about +Y maps the +X offset to -Z.
        #expect(simd_distance(pose.position, SIMD3(1, 0, -2.5)) < 1e-5)
    }

    @Test("Untracked and unknown anchors are reported as such")
    func untrackedAndMissing() {
        var resolver = AnchorResolver()
        #expect(resolver.status(of: item()) == .anchorMissing)
        resolver.update(WorldAnchorState(id: anchorID, pose: anchorPose, isTracked: false))
        #expect(resolver.status(of: item()) == .anchorNotTracked(lastKnown: anchorPose))
        resolver.remove(anchorID: anchorID)
        #expect(resolver.status(of: item()) == .anchorMissing)
    }

    @Test("An offset that overflows from a rotated anchor is reported as invalidPose, not placed")
    func overflowingOffset() {
        var resolver = AnchorResolver()
        let rotated = Pose(position: SIMD3(0, 0.8, -1), orientation: simd_quatf(angle: .pi / 4, axis: SIMD3(0, 1, 0)))
        let huge = AnchoredItem(anchorID: anchorID, kind: "lamp", offset: Pose(position: SIMD3(repeating: 3e38)))
        resolver.update(WorldAnchorState(id: anchorID, pose: rotated))
        #expect(resolver.status(of: huge) == .invalidPose)
        resolver.update(WorldAnchorState(id: anchorID, pose: rotated, isTracked: false))
        #expect(resolver.status(of: huge) == .invalidPose)
    }

    @Test("An item created at a world pose comes back at that pose")
    func worldPoseRoundTrip() throws {
        let anchor = WorldAnchorState(id: anchorID, pose: anchorPose)
        let worldPose = Pose(position: SIMD3(0.7, 0.9, -1.6), orientation: simd_quatf(angle: 0.4, axis: SIMD3(0, 1, 0)))
        let placed = AnchoredItem(kind: "lamp", worldPose: worldPose, anchor: anchor)
        #expect(placed.worldPose(anchorPose: anchor.pose).isApproximatelyEqual(to: worldPose))
    }

    @Test("The resolver refuses non-finite poses and new anchors beyond its capacity")
    func boundsAndValidation() {
        var resolver = AnchorResolver(capacity: 2)
        let accepted = [
            resolver.update(WorldAnchorState(id: UUID(), pose: Pose(position: SIMD3(.nan, 0, 0)))),
            resolver.update(WorldAnchorState(id: anchorID, pose: .identity)),
            resolver.update(WorldAnchorState(id: UUID(), pose: .identity)),
            resolver.update(WorldAnchorState(id: UUID(), pose: .identity)),
            resolver.update(WorldAnchorState(id: anchorID, pose: anchorPose))
        ]
        // NaN refused, two new anchors fill it, a third new one is refused, updating a known one works.
        #expect(accepted == [false, true, true, false, true])
        #expect(resolver.anchors.count == 2)
        #expect(AnchorResolver(capacity: 0).capacity == 1)
    }

    @Test("nearestTrackedAnchor picks the closest tracked anchor inside the radius")
    func nearestAnchor() {
        var resolver = AnchorResolver()
        let near = WorldAnchorState(id: UUID(), pose: Pose(position: SIMD3(0.2, 0, 0)))
        let nearer = WorldAnchorState(id: UUID(), pose: Pose(position: SIMD3(0.1, 0, 0)), isTracked: false)
        let far = WorldAnchorState(id: UUID(), pose: Pose(position: SIMD3(3, 0, 0)))
        [near, nearer, far].forEach { resolver.update($0) }
        #expect(resolver.nearestTrackedAnchor(to: .zero, within: 0.5) == near)
        #expect(resolver.nearestTrackedAnchor(to: .zero, within: 0.05) == nil)
        #expect(resolver.nearestTrackedAnchor(to: SIMD3(.nan, 0, 0), within: 10) == nil)
        #expect(resolver.nearestTrackedAnchor(to: .zero, within: -1) == nil)
    }

    @Test("unusedAnchorIDs lists anchors that no item references")
    func unusedAnchors() {
        var resolver = AnchorResolver()
        let unused = UUID()
        resolver.update(WorldAnchorState(id: anchorID, pose: .identity))
        resolver.update(WorldAnchorState(id: unused, pose: .identity))
        #expect(resolver.unusedAnchorIDs(given: [item()]) == [unused])
    }
}

@Suite("PlacementStore")
struct PlacementStoreTests {
    private func temporaryFile() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("ARCraftTests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("placements.json")
    }

    @Test("A missing file loads as an empty list")
    func missingFile() async throws {
        let contents = try await PlacementStore(fileURL: temporaryFile()).load()
        #expect(contents.items.isEmpty)
        #expect(contents.rejectedCount == 0)
    }

    @Test("Saved items load back, and removeAll deletes the file")
    func saveAndLoad() async throws {
        let url = temporaryFile()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let store = PlacementStore(fileURL: url)
        let items = [item("lamp"), item("chair", x: 1)]
        try await store.save(items)
        #expect(try await store.load().items == items)
        try await store.removeAll()
        try await store.removeAll()
        #expect(try await store.load().items.isEmpty)
    }

    @Test("A file larger than the limit is refused without reading all of it")
    func oversizedFile() async throws {
        let url = temporaryFile()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(repeating: 0x20, count: 10_000).write(to: url)
        let store = PlacementStore(fileURL: url, archive: PlacementArchive(limits: .init(maxBytes: 100)))
        await #expect(throws: PlacementArchiveError.tooLarge(byteCount: 101, limit: 100)) { try await store.load() }
    }

    @Test("A failed save leaves the previous file untouched")
    func failedSaveKeepsFile() async throws {
        let url = temporaryFile()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let store = PlacementStore(fileURL: url)
        let items = [item("lamp")]
        try await store.save(items)
        await #expect(throws: PlacementArchiveError.self) { try await store.save([item("")]) }
        #expect(try await store.load().items == items)
    }

    @Test("File names that could escape the folder are rejected", arguments: [
        "", ".hidden", "../escape.json", "a/b.json", "c:d", "nul\0.json", String(repeating: "a", count: 256)
    ])
    func rejectsUnsafeNames(name: String) {
        #expect(throws: PlacementStoreError.invalidFileName(name)) { try PlacementStore.applicationSupportFile(named: name) }
    }

    @Test("A plain file name resolves inside Application Support/ARCraft")
    func applicationSupportFile() throws {
        let url = try PlacementStore.applicationSupportFile(named: "room.json")
        #expect(url.lastPathComponent == "room.json")
        #expect(url.deletingLastPathComponent().lastPathComponent == "ARCraft")
    }
}
