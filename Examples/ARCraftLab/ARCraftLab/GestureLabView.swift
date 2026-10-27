import ARCraft
import SwiftUI

/// Classifies a synthetic hand live and replays a recorded pinch through the recognizer.
struct GestureLabView: View {
    @State private var shape: HandShape = .pinch
    @State private var closing = 0.85

    private let classifier = HandShapeClassifier()
    private let recognizerSettings = HandGestureRecognizer.Configuration(shape: .pinch)

    private var pose: HandPose {
        guard shape == .pinch else { return SyntheticHand(shape).pose() }
        return SyntheticHand.openPalm.interpolated(to: .pinch, fraction: Float(closing)).pose()
    }

    var body: some View {
        let reading = classifier.classify(pose)
        List {
            Section {
                HandSkeletonView(pose: pose, highlight: reading.shape)
                    .frame(height: 230)
                Picker("Hand", selection: $shape) {
                    ForEach(HandShape.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                if shape == .pinch {
                    LabeledContent("Closing") {
                        Slider(value: $closing, in: 0...1)
                    }
                }
            }
            Section("Classifier") {
                LabeledContent("Shape", value: reading.shape.label)
                LabeledContent("Pinch distance", value: reading.pinchDistance.map { String(format: "%.2f", $0) } ?? "–")
                ForEach(Finger.fingers, id: \.self) { finger in
                    ExtensionRow(finger: finger, ratio: reading.fingerExtension[finger] ?? 0)
                }
            }
            Section {
                ForEach(Array(Self.replay(settings: recognizerSettings).enumerated()), id: \.offset) { _, line in
                    Text(line).font(.callout.monospaced())
                }
            } header: {
                Text("Recognizer replay")
            } footer: {
                Text("A pinch begins at a distance of \(recognizerSettings.classifier.pinchDistance, specifier: "%.2f") and lasts until \(recognizerSettings.pinchReleaseDistance, specifier: "%.2f"), so it does not flicker at the edge.")
            }
        }
    }

    /// Feeds a recorded pinch (closing amounts at 90 Hz) to a recognizer and describes the events.
    static func replay(settings: HandGestureRecognizer.Configuration) -> [String] {
        let script: [(amount: Float, note: String)] = [
            (0.0, "open"), (0.6, "closing"), (0.6, "almost"), (1.0, "touching"), (1.0, "touching"),
            (0.65, "eased open"), (0.65, "eased open"), (0.3, "opening"), (0.2, "opening"), (0.0, "open")
        ]
        var recognizer = HandGestureRecognizer(configuration: settings)
        return script.enumerated().map { frame, step in
            let pose = SyntheticHand.openPalm.interpolated(to: .pinch, fraction: step.amount).pose(timestamp: Double(frame) / 90)
            let events = recognizer.update(with: pose).map(\.label).joined(separator: ", ")
            return "\(frame)  \(step.note.padding(toLength: 11, withPad: " ", startingAt: 0)) \(events.isEmpty ? "·" : events)"
        }
    }
}

private struct ExtensionRow: View {
    let finger: Finger
    let ratio: Float

    var body: some View {
        LabeledContent(finger.rawValue.capitalized) {
            HStack {
                ProgressView(value: Double(min(max(ratio, 0), 2)), total: 2)
                    .frame(maxWidth: 140)
                Text(String(format: "%.2f", ratio))
                    .font(.callout.monospacedDigit())
            }
        }
    }
}

extension HandShape {
    var label: String {
        switch self {
        case .pinch: "Pinch"
        case .point: "Point"
        case .fist: "Fist"
        case .openPalm: "Open"
        case .other: "Other"
        }
    }
}

extension HandGestureEvent {
    var label: String {
        switch self {
        case .began: "began"
        case .changed: "changed"
        case .ended: "ended"
        case .cancelled: "cancelled"
        }
    }
}

#Preview {
    NavigationStack { GestureLabView() }
}
