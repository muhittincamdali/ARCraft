import ARCraft
import Foundation
import SwiftUI

/// Saves four items on three world anchors, damages the file if asked, reads it back and shows
/// where each item would appear.
struct PersistenceLabView: View {
    @State private var damagesFile = false

    var body: some View {
        let result = RoomArchiveDemo.run(damagingFile: damagesFile)
        List {
            Section {
                ForEach(result.rows) { row in
                    LabeledContent {
                        Text(row.status).foregroundStyle(row.isPlaced ? LabPalette.blue : LabPalette.muted)
                    } label: {
                        Label(row.kind, systemImage: row.isPlaced ? "cube.fill" : "cube")
                    }
                }
            } header: {
                Text("After restoring")
            } footer: {
                Text("The desk anchor is tracked, the shelf is in another room, and the hallway anchor has not been reported yet.")
            }
            Section("Archive") {
                Toggle("Damage one entry in the file", isOn: $damagesFile)
                LabeledContent("Size", value: "\(result.byteCount) bytes")
                LabeledContent("Items read", value: "\(result.rows.count)")
                LabeledContent("Items skipped", value: "\(result.rejectedCount)")
                Text(result.preview)
                    .font(.caption.monospaced())
                    .foregroundStyle(LabPalette.muted)
                    .lineLimit(6)
            }
        }
    }
}

/// The persistence round trip behind ``PersistenceLabView``, kept free of UI.
enum RoomArchiveDemo {
    struct Row: Identifiable {
        let id: UUID
        let kind: String
        let status: String
        let isPlaced: Bool
    }

    struct Result {
        let rows: [Row]
        let rejectedCount: Int
        let byteCount: Int
        let preview: String
    }

    private static let desk = WorldAnchorState(id: UUID(uuidString: "0A84FF00-0000-4000-8000-000000000001")!,
                                               pose: Pose(position: SIMD3(0.5, 0.75, -1)))
    private static let shelf = WorldAnchorState(id: UUID(uuidString: "0A84FF00-0000-4000-8000-000000000002")!,
                                                pose: Pose(position: SIMD3(-1.2, 1.4, -2)), isTracked: false)
    private static let hallwayID = UUID(uuidString: "0A84FF00-0000-4000-8000-000000000003")!

    private static let items: [AnchoredItem] = [
        AnchoredItem(id: UUID(uuidString: "5AC8FA00-0000-4000-8000-000000000001")!, kind: "Lamp",
                     worldPose: Pose(position: SIMD3(0.35, 0.75, -1.1)), anchor: desk),
        AnchoredItem(id: UUID(uuidString: "5AC8FA00-0000-4000-8000-000000000002")!, kind: "Plant",
                     worldPose: Pose(position: SIMD3(0.7, 0.75, -0.95)), anchor: desk, attributes: ["pot": "blue"]),
        AnchoredItem(id: UUID(uuidString: "5AC8FA00-0000-4000-8000-000000000003")!, kind: "Book",
                     worldPose: Pose(position: SIMD3(-1.1, 1.4, -2)), anchor: shelf),
        AnchoredItem(id: UUID(uuidString: "5AC8FA00-0000-4000-8000-000000000004")!, anchorID: hallwayID, kind: "Poster")
    ]

    static func run(damagingFile: Bool) -> Result {
        let archive = PlacementArchive()
        guard var data = try? archive.encode(items) else {
            return Result(rows: [], rejectedCount: 0, byteCount: 0, preview: "Encoding failed")
        }
        if damagingFile, let damaged = zeroingFirstOrientation(in: data) {
            data = damaged
        }
        var resolver = AnchorResolver()
        resolver.update(desk)
        resolver.update(shelf)
        guard let contents = try? archive.decode(data) else {
            return Result(rows: [], rejectedCount: items.count, byteCount: data.count, preview: "Unreadable archive")
        }
        let rows = contents.items.map { item in
            Row(id: item.id, kind: item.kind, status: describe(resolver.status(of: item)), isPlaced: isPlaced(resolver.status(of: item)))
        }
        return Result(rows: rows, rejectedCount: contents.rejectedCount, byteCount: data.count,
                      preview: String(decoding: data.prefix(420), as: UTF8.self) + "…")
    }

    /// Zeroes the first item's orientation: a quaternion of length zero is not a rotation.
    private static func zeroingFirstOrientation(in data: Data) -> Data? {
        guard var root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              var items = root["items"] as? [[String: Any]], var first = items.first,
              var offset = first["offset"] as? [String: Any] else { return nil }
        offset["orientation"] = [0, 0, 0, 0]
        first["offset"] = offset
        items[0] = first
        root["items"] = items
        return try? JSONSerialization.data(withJSONObject: root, options: [.sortedKeys])
    }

    private static func isPlaced(_ status: ItemStatus) -> Bool {
        if case .placed = status { true } else { false }
    }

    private static func describe(_ status: ItemStatus) -> String {
        switch status {
        case .placed(let pose): String(format: "at %.2f, %.2f, %.2f", pose.position.x, pose.position.y, pose.position.z)
        case .anchorNotTracked: "anchor not tracked"
        case .anchorMissing: "anchor missing"
        }
    }
}

#Preview {
    NavigationStack { PersistenceLabView() }
}
