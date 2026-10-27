import Foundation
import Testing
import simd
@testable import ARCraft

@Suite("HandGestureRecognizer")
struct HandGestureRecognizerTests {
    private let frame: TimeInterval = 1.0 / 90

    /// A right hand closing toward a pinch: `amount` 0 is open, 1 is touching.
    private func pinch(_ amount: Float, at index: Int) -> HandPose {
        SyntheticHand.openPalm.interpolated(to: .pinch, fraction: 1)
            .withPinch(amount)
            .pose(timestamp: Double(index) * frame)
    }

    private func kinds(_ events: [HandGestureEvent]) -> [String] {
        events.map { event in
            switch event {
            case .began: "began"
            case .changed: "changed"
            case .ended: "ended"
            case .cancelled: "cancelled"
            }
        }
    }

    @Test("A pinch begins after two matching frames and changes after that")
    func beginsAfterDebounce() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .pinch))
        #expect(recognizer.update(with: pinch(1, at: 0)).isEmpty)
        #expect(kinds(recognizer.update(with: pinch(1, at: 1))) == ["began"])
        #expect(kinds(recognizer.update(with: pinch(1, at: 2))) == ["changed"])
        #expect(recognizer.isActive)
    }

    @Test("A single matching frame between open frames never begins")
    func ignoresFlicker() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .pinch))
        var events: [HandGestureEvent] = []
        for (index, amount) in [0, 1, 0, 1, 0, 1, 0].enumerated() {
            events += recognizer.update(with: pinch(Float(amount), at: index))
        }
        #expect(events.isEmpty)
    }

    @Test("Hysteresis: a pinch that opens a little stays active, opening further ends it")
    func pinchHysteresis() throws {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .pinch))
        let classifier = HandShapeClassifier()
        let between = pinch(0.65, at: 10)
        let distance = try #require(classifier.classify(between).pinchDistance)
        // Too wide to start a pinch, close enough to keep one going.
        #expect(distance > recognizer.configuration.classifier.pinchDistance)
        #expect(distance < recognizer.configuration.pinchReleaseDistance)

        #expect(kinds(recognizer.update(with: pinch(0.65, at: 0)) + recognizer.update(with: pinch(0.65, at: 1))).isEmpty)
        _ = recognizer.update(with: pinch(1, at: 2))
        _ = recognizer.update(with: pinch(1, at: 3))
        #expect(recognizer.isActive)
        #expect(kinds(recognizer.update(with: pinch(0.65, at: 4))) == ["changed"])

        let lastHeld = pinch(0.65, at: 4)
        #expect(recognizer.update(with: pinch(0.4, at: 5)).isEmpty)
        #expect(recognizer.update(with: pinch(0.4, at: 6)).isEmpty)
        let ended = recognizer.update(with: pinch(0.4, at: 7))
        #expect(ended == [.ended(lastHeld)])
        #expect(!recognizer.isActive)
    }

    @Test("Frames that do not move forward in time are ignored")
    func ignoresStaleFrames() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .pinch, framesToBegin: 2))
        _ = recognizer.update(with: pinch(1, at: 5))
        #expect(recognizer.update(with: pinch(1, at: 5)).isEmpty)
        #expect(recognizer.update(with: pinch(1, at: 3)).isEmpty)
        #expect(!recognizer.isActive)
        #expect(kinds(recognizer.update(with: pinch(1, at: 6))) == ["began"])
    }

    @Test("A long gap cancels the gesture; the returning hand starts over")
    func gapCancels() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .pinch, framesToBegin: 1))
        _ = recognizer.update(with: pinch(1, at: 0))
        #expect(recognizer.isActive)
        let events = recognizer.update(with: pinch(1, at: 90))
        #expect(kinds(events) == ["cancelled", "began"])
    }

    @Test("trackingLost cancels only after the tolerance and only while active")
    func trackingLost() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .fist, framesToBegin: 1, trackingLossTolerance: 0.2))
        #expect(recognizer.trackingLost(at: 1) == nil)
        _ = recognizer.update(with: SyntheticHand.fist.pose(timestamp: 1))
        #expect(recognizer.trackingLost(at: 1.1) == nil)
        #expect(recognizer.isActive)
        #expect(recognizer.trackingLost(at: .nan) == nil)
        #expect(recognizer.trackingLost(at: 1.3) == .cancelled)
        #expect(!recognizer.isActive)
        #expect(recognizer.trackingLost(at: 1.4) == nil)
    }

    @Test("Other shapes end after framesToEnd non-matching frames")
    func shapeEnds() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .point, framesToBegin: 1, framesToEnd: 2))
        #expect(kinds(recognizer.update(with: SyntheticHand.point.pose(timestamp: 0))) == ["began"])
        #expect(recognizer.update(with: SyntheticHand.openPalm.pose(timestamp: 0.01)).isEmpty)
        #expect(kinds(recognizer.update(with: SyntheticHand.point.pose(timestamp: 0.02))) == ["changed"])
        #expect(recognizer.update(with: SyntheticHand.openPalm.pose(timestamp: 0.03)).isEmpty)
        #expect(kinds(recognizer.update(with: SyntheticHand.openPalm.pose(timestamp: 0.04))) == ["ended"])
    }

    @Test("A long run of frames keeps the counters bounded")
    func longRun() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .pinch))
        var began = 0
        for index in 0..<20_000 {
            began += recognizer.update(with: pinch(1, at: index)).filter { if case .began = $0 { true } else { false } }.count
        }
        #expect(began == 1)
        #expect(recognizer.isActive)
    }

    @Test("Settings are clamped into range")
    func clampsConfiguration() {
        let configuration = HandGestureRecognizer.Configuration(shape: .pinch, framesToBegin: -4, framesToEnd: 10_000,
                                                               pinchReleaseDistance: 0.1, trackingLossTolerance: .nan)
        #expect(configuration.framesToBegin == 1)
        #expect(configuration.framesToEnd == 120)
        #expect(configuration.pinchReleaseDistance == configuration.classifier.pinchDistance)
        #expect(configuration.trackingLossTolerance == 0.25)
    }

    @Test("reset() forgets the gesture without an event")
    func reset() {
        var recognizer = HandGestureRecognizer(configuration: .init(shape: .pinch, framesToBegin: 1))
        _ = recognizer.update(with: pinch(1, at: 0))
        recognizer.reset()
        #expect(!recognizer.isActive)
        #expect(kinds(recognizer.update(with: pinch(1, at: 0))) == ["began"])
    }
}

private extension SyntheticHand {
    func withPinch(_ amount: Float) -> SyntheticHand {
        SyntheticHand(curl: curl, pinch: amount)
    }
}
