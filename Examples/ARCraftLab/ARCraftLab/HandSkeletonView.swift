import ARCraft
import SwiftUI
import simd

/// Draws a hand pose seen from the front (x to the right, y up), scaled to fit the view.
struct HandSkeletonView: View {
    let pose: HandPose
    var highlight: HandShape = .other

    private static let bones: [(HandJoint, HandJoint)] = {
        var bones: [(HandJoint, HandJoint)] = [(.wrist, .thumbKnuckle)]
        for finger in Finger.allCases {
            if finger != .thumb { bones.append((.wrist, finger.knuckle)) }
            bones += zip(finger.joints, finger.joints.dropFirst()).map { ($0, $1) }
        }
        bones += [(.indexFingerKnuckle, .middleFingerKnuckle), (.middleFingerKnuckle, .ringFingerKnuckle),
                  (.ringFingerKnuckle, .littleFingerKnuckle)]
        return bones
    }()

    var body: some View {
        Canvas { context, size in
            guard let mapping = Mapping(pose: pose, size: size) else { return }
            var path = Path()
            for (from, to) in Self.bones {
                guard let a = pose[from], let b = pose[to] else { continue }
                path.move(to: mapping.point(a))
                path.addLine(to: mapping.point(b))
            }
            context.stroke(path, with: .color(LabPalette.sky), style: StrokeStyle(lineWidth: 5, lineCap: .round))
            for (joint, position) in pose.joints where joint != .forearmArm && joint != .forearmWrist {
                let isTip = Finger.allCases.contains { $0.tip == joint }
                let radius: CGFloat = isTip ? 7 : 4
                let center = mapping.point(position)
                let dot = Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
                context.fill(dot, with: .color(isTip ? highlightColor : LabPalette.deep))
            }
        }
        .accessibilityLabel("Hand skeleton")
    }

    private var highlightColor: Color {
        highlight == .other ? LabPalette.navy : LabPalette.blue
    }

    /// Fits the joints (without the forearm) into the view, keeping the aspect ratio.
    private struct Mapping {
        let origin: SIMD2<Float>
        let scale: Float
        let size: CGSize

        init?(pose: HandPose, size: CGSize) {
            let points = pose.joints.filter { $0.key != .forearmArm }.values.map { SIMD2($0.x, $0.y) }
            guard let first = points.first else { return nil }
            let lower = points.reduce(first) { simd_min($0, $1) }
            let upper = points.reduce(first) { simd_max($0, $1) }
            let extent = simd_max(upper - lower, SIMD2(repeating: 1e-6))
            let usable = SIMD2(Float(size.width), Float(size.height)) * 0.82
            scale = min(usable.x / extent.x, usable.y / extent.y)
            origin = (lower + upper) / 2
            self.size = size
        }

        func point(_ position: SIMD3<Float>) -> CGPoint {
            let offset = (SIMD2(position.x, position.y) - origin) * scale
            return CGPoint(x: size.width / 2 + CGFloat(offset.x), y: size.height / 2 - CGFloat(offset.y))
        }
    }
}
