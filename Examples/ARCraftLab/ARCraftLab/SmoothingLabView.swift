import ARCraft
import Charts
import SwiftUI

/// Shows a jittery fingertip track before and after the One Euro filter.
struct SmoothingLabView: View {
    @State private var minimumCutoff = 1.5
    @State private var speedCoefficient = 8.0

    private var configuration: OneEuroConfiguration {
        OneEuroConfiguration(minimumCutoff: Float(minimumCutoff), speedCoefficient: Float(speedCoefficient))
    }

    var body: some View {
        let track = FingertipTrack.make(configuration: configuration)
        List {
            Section {
                Chart {
                    ForEach(track.samples) { sample in
                        LineMark(x: .value("Time", sample.time), y: .value("mm", sample.raw), series: .value("Signal", "Tracked"))
                            .foregroundStyle(LabPalette.sky.opacity(0.7))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        LineMark(x: .value("Time", sample.time), y: .value("mm", sample.smoothed), series: .value("Signal", "Filtered"))
                            .foregroundStyle(LabPalette.deep)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                    }
                }
                .chartXAxisLabel("seconds")
                .chartYAxisLabel("mm")
                .chartYScale(domain: -10...110)
                .frame(height: 180)
                Chart {
                    ForEach(track.samples.prefix(Int(FingertipTrack.rate * FingertipTrack.moveStart))) { sample in
                        LineMark(x: .value("Time", sample.time), y: .value("mm", sample.raw), series: .value("Signal", "Tracked"))
                            .foregroundStyle(LabPalette.sky)
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        LineMark(x: .value("Time", sample.time), y: .value("mm", sample.smoothed), series: .value("Signal", "Filtered"))
                            .foregroundStyle(LabPalette.deep)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                    }
                }
                .chartYScale(domain: -4...4)
                .chartYAxisLabel("mm, at rest")
                .frame(height: 120)
            } footer: {
                Text("Light: tracked. Dark: filtered. A fingertip at rest with ±3 mm of tracking noise, then a 10 cm move in 0.2 s; the lower chart zooms into the first second.")
            }
            Section("Result") {
                LabeledContent("Jitter at rest", value: String(format: "%.2f → %.2f mm", track.rawJitter, track.smoothedJitter))
                LabeledContent("Time to 90 % of the move", value: String(format: "%.0f ms", track.delay * 1000))
            }
            Section("Filter") {
                LabeledContent("Minimum cutoff") {
                    Slider(value: $minimumCutoff, in: 0.2...5)
                    Text(String(format: "%.1f Hz", minimumCutoff)).font(.callout.monospacedDigit())
                }
                LabeledContent("Speed coefficient") {
                    Slider(value: $speedCoefficient, in: 0...20)
                    Text(String(format: "%.1f", speedCoefficient)).font(.callout.monospacedDigit())
                }
            }
        }
    }
}

/// A deterministic fingertip recording and its filtered version.
struct FingertipTrack {
    struct Sample: Identifiable {
        let id: Int
        let time: Double
        let raw: Float
        let smoothed: Float
    }

    let samples: [Sample]
    /// Standard deviation during the first second, in millimeters.
    let rawJitter: Float
    let smoothedJitter: Float
    /// Seconds from the start of the move until the filtered value reaches 90 % of it.
    let delay: Double

    static let rate = 90.0
    static let moveStart = 1.0
    static let moveDuration = 0.2

    static func make(configuration: OneEuroConfiguration) -> FingertipTrack {
        var filter = OneEuroFilter<SIMD3<Float>>(configuration: configuration)
        var state: UInt64 = 7
        var samples: [Sample] = []
        for frame in 0..<Int(rate * 2) {
            let time = Double(frame) / rate
            let progress = min(max((time - moveStart) / moveDuration, 0), 1)
            state = state &* 6364136223846793005 &+ 1442695040888963407
            let noise = (Float(state >> 40) / Float(1 << 24) * 2 - 1) * 3
            let raw = Float(progress) * 100 + noise
            let smoothed = filter.filter(SIMD3(raw / 1000, 0, 0), at: time).map { $0.x * 1000 } ?? raw
            samples.append(Sample(id: frame, time: time, raw: raw, smoothed: smoothed))
        }
        let rest = samples.prefix(Int(rate * moveStart))
        let reached = samples.first { $0.time >= moveStart && $0.smoothed >= 90 }?.time ?? 2
        return FingertipTrack(samples: samples, rawJitter: deviation(rest.map(\.raw)),
                              smoothedJitter: deviation(rest.dropFirst(10).map(\.smoothed)), delay: reached - moveStart)
    }

    private static func deviation(_ values: [Float]) -> Float {
        guard !values.isEmpty else { return 0 }
        let mean = values.reduce(0, +) / Float(values.count)
        return (values.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Float(values.count)).squareRoot()
    }
}

#Preview {
    NavigationStack { SmoothingLabView() }
}
