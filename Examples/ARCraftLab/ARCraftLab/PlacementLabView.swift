import ARCraft
import SwiftUI

/// A top-down room: tap the floor or the wall and the solver places an object there, turned toward
/// the viewer, with optional grid and rotation snapping.
struct PlacementLabView: View {
    @State private var snapsToGrid = true
    @State private var snapsRotation = true
    @State private var taps: [SIMD2<Float>] = RoomMap.initialTaps

    private var solver: PlacementSolver {
        PlacementSolver(options: .init(gridSize: snapsToGrid ? 0.25 : nil, rotationStep: snapsRotation ? .pi / 4 : nil))
    }

    private var placements: [Placement] {
        taps.compactMap { try? solver.place(on: RoomMap.hit(at: $0), facing: RoomMap.viewer) }
    }

    var body: some View {
        let placements = placements
        List {
            Section {
                RoomCanvas(placements: placements, showsGrid: snapsToGrid) { location in
                    taps.append(RoomMap.worldPoint(from: location, in: RoomMap.canvasSize))
                }
            } footer: {
                Text("Tap the floor or the wall (top edge). You stand at the bottom; objects turn to face you.")
            }
            Section("Snapping") {
                Toggle("25 cm grid", isOn: $snapsToGrid)
                Toggle("45° turns", isOn: $snapsRotation)
                Button("Clear") { taps = [] }
            }
            Section("Placements") {
                ForEach(Array(placements.enumerated()), id: \.offset) { _, placement in
                    LabeledContent(placement.surface.rawValue.capitalized, value: RoomMap.describe(placement))
                        .font(.callout.monospacedDigit())
                }
            }
        }
    }
}

/// The room's geometry and the mapping between the canvas and world space (meters, y up).
enum RoomMap {
    static let xRange: ClosedRange<Float> = -1.5...1.5
    static let zRange: ClosedRange<Float> = -3...0.5
    static let wallZ: Float = -3
    static let viewer = SIMD3<Float>(0, 1.6, 0.25)
    /// The canvas is drawn at a fixed size so taps map the same way on every device.
    static let canvasSize = CGSize(width: 300, height: 300)
    static let initialTaps: [SIMD2<Float>] = [SIMD2(-0.9, -1.1), SIMD2(0.8, -1.7), SIMD2(0.1, -2.2), SIMD2(-0.4, wallZ), SIMD2(0.9, wallZ)]

    static var scale: Float {
        min(Float(canvasSize.width) / (xRange.upperBound - xRange.lowerBound),
            Float(canvasSize.height) / (zRange.upperBound - zRange.lowerBound))
    }

    /// A tap within 12 points of the top edge hits the wall at 1.2 m height; anything else hits the floor.
    static func hit(at point: SIMD2<Float>) -> SurfaceHit {
        if point.y <= wallZ + 0.05 {
            return SurfaceHit(position: SIMD3(point.x, 1.2, wallZ), normal: SIMD3(0, 0, 1))
        }
        return SurfaceHit(position: SIMD3(point.x, 0, point.y), normal: SIMD3(0, 1, 0))
    }

    static func worldPoint(from location: CGPoint, in size: CGSize) -> SIMD2<Float> {
        let x = Float(location.x - size.width / 2) / scale
        let z = zRange.lowerBound + Float(location.y) / scale
        let snappedZ = Float(location.y) < 12 ? wallZ : z
        return SIMD2(min(max(x, xRange.lowerBound), xRange.upperBound), min(max(snappedZ, wallZ), zRange.upperBound))
    }

    static func canvasPoint(x: Float, z: Float, in size: CGSize) -> CGPoint {
        CGPoint(x: size.width / 2 + CGFloat(x * scale), y: CGFloat((z - zRange.lowerBound) * scale))
    }

    static func describe(_ placement: Placement) -> String {
        let position = placement.pose.position
        let front = placement.pose.rotate(SIMD3(0, 0, 1))
        let yaw = atan2(front.x, front.z) * 180 / .pi
        return String(format: "x %.2f  z %.2f  turn %.0f°", position.x, position.z, yaw)
    }
}

private struct RoomCanvas: View {
    let placements: [Placement]
    let showsGrid: Bool
    let onTap: (CGPoint) -> Void

    var body: some View {
        Canvas { context, size in
            drawRoom(in: &context, size: size)
            for placement in placements {
                drawObject(placement, in: &context, size: size)
            }
        }
        .frame(width: RoomMap.canvasSize.width, height: RoomMap.canvasSize.height)
        .contentShape(Rectangle())
        .gesture(SpatialTapGesture().onEnded { onTap($0.location) })
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Room seen from above with \(placements.count) placed objects")
    }

    private func drawRoom(in context: inout GraphicsContext, size: CGSize) {
        let floor = CGRect(origin: .zero, size: size)
        context.fill(Path(floor), with: .color(LabPalette.sky.opacity(0.12)))
        if showsGrid {
            var grid = Path()
            for step in stride(from: RoomMap.xRange.lowerBound, through: RoomMap.xRange.upperBound, by: 0.25) {
                grid.move(to: RoomMap.canvasPoint(x: step, z: RoomMap.zRange.lowerBound, in: size))
                grid.addLine(to: RoomMap.canvasPoint(x: step, z: RoomMap.zRange.upperBound, in: size))
            }
            for step in stride(from: RoomMap.zRange.lowerBound, through: RoomMap.zRange.upperBound, by: 0.25) {
                grid.move(to: RoomMap.canvasPoint(x: RoomMap.xRange.lowerBound, z: step, in: size))
                grid.addLine(to: RoomMap.canvasPoint(x: RoomMap.xRange.upperBound, z: step, in: size))
            }
            context.stroke(grid, with: .color(LabPalette.sky.opacity(0.35)), lineWidth: 0.5)
        }
        context.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: 6)), with: .color(LabPalette.navy))
        let viewer = RoomMap.canvasPoint(x: RoomMap.viewer.x, z: RoomMap.viewer.z, in: size)
        context.fill(Path(ellipseIn: CGRect(x: viewer.x - 9, y: viewer.y - 9, width: 18, height: 18)), with: .color(LabPalette.deep))
        context.draw(Text("you").font(.caption2).foregroundStyle(.white), at: viewer)
    }

    private func drawObject(_ placement: Placement, in context: inout GraphicsContext, size: CGSize) {
        let position = placement.pose.position
        let center = RoomMap.canvasPoint(x: position.x, z: position.z, in: size)
        let front = placement.pose.rotate(SIMD3(0, 0, 1))
        let angle = Angle(radians: Double(atan2(front.x, front.z)))
        var object = context
        object.translateBy(x: center.x, y: center.y + (placement.surface == .wall ? 10 : 0))
        object.rotate(by: -angle)
        let body = Path(roundedRect: CGRect(x: -12, y: -9, width: 24, height: 18), cornerRadius: 4)
        object.fill(body, with: .color(LabPalette.blue))
        var arrow = Path()
        arrow.move(to: CGPoint(x: 0, y: 4))
        arrow.addLine(to: CGPoint(x: 0, y: 22))
        arrow.move(to: CGPoint(x: -5, y: 16))
        arrow.addLine(to: CGPoint(x: 0, y: 22))
        arrow.addLine(to: CGPoint(x: 5, y: 16))
        object.stroke(arrow, with: .color(LabPalette.sky), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}

#Preview {
    NavigationStack { PlacementLabView() }
}
