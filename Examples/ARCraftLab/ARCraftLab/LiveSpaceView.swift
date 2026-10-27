#if os(visionOS)
import ARCraft
import RealityKit
import SwiftUI

/// The immersive space: a cursor on the right index fingertip, and a cube wherever a pinch ends.
struct LiveSpaceView: View {
    static let spaceID = "live-space"

    @State private var model = LiveSpaceModel()
    @State private var root = Entity()
    @State private var cursor = ModelEntity(mesh: .generateSphere(radius: 0.008),
                                            materials: [SimpleMaterial(color: .systemBlue, isMetallic: false)])

    var body: some View {
        RealityView { content, attachments in
            root.addChild(cursor)
            content.add(root)
            if let panel = attachments.entity(for: "status") {
                panel.position = SIMD3(0, 1.3, -1.2)
                root.addChild(panel)
            }
        } update: { _, _ in
            synchronize()
        } attachments: {
            Attachment(id: "status") {
                StatusPanel(model: model)
            }
        }
        .task { await model.run() }
    }

    /// Moves the cursor and creates, moves or hides one cube per stored item.
    private func synchronize() {
        cursor.isEnabled = model.fingertip != nil
        if let tip = model.fingertip { cursor.position = tip }
        cursor.scale = SIMD3(repeating: model.isPinching ? 1.6 : 1)
        let wanted = Set(model.items.map(\.id.uuidString))
        for child in root.children where child.name.hasPrefix("item-") && !wanted.contains(String(child.name.dropFirst(5))) {
            child.removeFromParent()
        }
        for item in model.items {
            let entity = root.findEntity(named: "item-\(item.id.uuidString)") ?? makeCube(for: item)
            switch model.resolver.status(of: item) {
            case .placed(let pose):
                entity.isEnabled = true
                entity.setPose(pose)
            case .anchorNotTracked, .anchorMissing, .invalidPose:
                entity.isEnabled = false
            }
        }
    }

    private func makeCube(for item: AnchoredItem) -> Entity {
        let cube = ModelEntity(mesh: .generateBox(size: 0.05, cornerRadius: 0.008),
                               materials: [SimpleMaterial(color: .systemBlue, roughness: 0.4, isMetallic: false)])
        cube.name = "item-\(item.id.uuidString)"
        root.addChild(cube)
        return cube
    }
}

private struct StatusPanel: View {
    let model: LiveSpaceModel

    var body: some View {
        VStack(spacing: 12) {
            Text(message).font(.title3)
            Text("\(model.items.count) cubes saved").foregroundStyle(.secondary)
            Button("Remove all cubes") { Task { await model.clear() } }
                .disabled(model.items.isEmpty)
        }
        .padding(24)
        .glassBackgroundEffect()
    }

    private var message: String {
        switch model.status {
        case .idle: "Starting tracking…"
        case .running: model.isPinching ? "Release to place a cube" : "Pinch with your right hand to place a cube"
        case .unavailable(let reason), .failed(let reason): reason
        }
    }
}
#endif
