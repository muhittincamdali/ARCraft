import Foundation

/// An event from ``HandGestureRecognizer``.
public enum HandGestureEvent: Sendable, Hashable {
    /// The shape has been held for the configured number of frames.
    case began(HandPose)
    /// The shape is still held; the pose is the current frame.
    case changed(HandPose)
    /// The hand left the shape. The pose is the last frame that still matched, which is where a
    /// pinch was released.
    case ended(HandPose)
    /// The hand was lost for longer than the configured tolerance while the shape was held.
    case cancelled
}

/// Turns per-frame hand poses into began, changed, ended and cancelled events for one hand shape.
///
/// A classifier on its own flickers: a pinch measured at exactly the threshold switches on and off
/// from frame to frame. The recognizer adds three things on top of ``HandShapeClassifier``:
///
/// - **Debounce.** The shape must match for `framesToBegin` frames in a row to begin, and fail
///   for `framesToEnd` frames in a row to end.
/// - **Hysteresis for pinches.** Once a pinch has begun it lasts until the fingers open past
///   `pinchReleaseDistance`, which is wider than the distance needed to start it.
/// - **Tracking loss.** Short drop-outs are bridged; a gap longer than `trackingLossTolerance`
///   cancels the gesture rather than ending it, so a lost hand never counts as a release.
///
/// ```swift
/// var pinch = HandGestureRecognizer(configuration: .init(shape: .pinch))
/// for event in pinch.update(with: pose) {
///     switch event {
///     case .began(let pose): startDrag(at: pose[.indexFingerTip])
///     case .changed(let pose): drag(to: pose[.indexFingerTip])
///     case .ended(let pose): drop(at: pose[.indexFingerTip])
///     case .cancelled: cancelDrag()
///     }
/// }
/// ```
public struct HandGestureRecognizer: Sendable {
    /// The settings of a recognizer.
    public struct Configuration: Sendable, Hashable {
        /// The shape to recognize.
        public var shape: HandShape
        /// Consecutive matching frames needed to begin, in `1...120`.
        public var framesToBegin: Int
        /// Consecutive non-matching frames needed to end, in `1...120`.
        public var framesToEnd: Int
        /// A pinch in progress lasts until the normalized thumb-to-index distance exceeds this.
        /// Never smaller than the classifier's `pinchDistance`.
        public var pinchReleaseDistance: Float
        /// The longest gap between frames, in seconds, that does not cancel the gesture.
        public var trackingLossTolerance: TimeInterval
        /// The thresholds of the underlying classifier.
        public var classifier: HandShapeClassifier.Configuration

        /// Creates a configuration. Out-of-range values are clamped or replaced with defaults.
        public init(shape: HandShape, framesToBegin: Int = 2, framesToEnd: Int = 3,
                    pinchReleaseDistance: Float = 0.4, trackingLossTolerance: TimeInterval = 0.25,
                    classifier: HandShapeClassifier.Configuration = .init()) {
            let frameRange = 1...120
            self.shape = shape
            self.framesToBegin = min(max(framesToBegin, frameRange.lowerBound), frameRange.upperBound)
            self.framesToEnd = min(max(framesToEnd, frameRange.lowerBound), frameRange.upperBound)
            let release = pinchReleaseDistance.isFinite ? pinchReleaseDistance : 0.4
            self.pinchReleaseDistance = max(release, classifier.pinchDistance)
            self.trackingLossTolerance = trackingLossTolerance.isFinite && trackingLossTolerance > 0 ? trackingLossTolerance : 0.25
            self.classifier = classifier
        }
    }

    /// The recognizer's settings.
    public let configuration: Configuration
    /// `true` between `began` and `ended` or `cancelled`.
    public private(set) var isActive = false
    private let classifier: HandShapeClassifier
    private var matchingFrames = 0
    private var missingFrames = 0
    private var lastSeen: TimeInterval?
    private var lastMatch: HandPose?

    /// Creates a recognizer.
    public init(configuration: Configuration) {
        self.configuration = configuration
        classifier = HandShapeClassifier(configuration: configuration.classifier)
    }

    /// Feeds one frame and returns the events it causes: none, one, or `cancelled` followed by
    /// `began` when the hand comes back after a long gap. Frames whose timestamp is not later than
    /// the previous frame are ignored.
    public mutating func update(with pose: HandPose) -> [HandGestureEvent] {
        var events: [HandGestureEvent] = []
        if let lastSeen {
            guard pose.timestamp > lastSeen else { return [] }
            if pose.timestamp - lastSeen > configuration.trackingLossTolerance {
                if isActive { events.append(.cancelled) }
                clearProgress()
            }
        }
        lastSeen = pose.timestamp
        if let event = advance(with: pose, matches: matches(pose)) {
            events.append(event)
        }
        return events
    }

    /// Tells the recognizer that no pose was available at `time`, for example because ARKit
    /// reported the hand as not tracked. Returns `cancelled` once the gap since the last frame
    /// exceeds the tolerance while the gesture is active.
    public mutating func trackingLost(at time: TimeInterval) -> HandGestureEvent? {
        guard time.isFinite, let lastSeen, time - lastSeen > configuration.trackingLossTolerance else { return nil }
        let wasActive = isActive
        clearProgress()
        return wasActive ? .cancelled : nil
    }

    /// Returns the recognizer to its initial state without emitting an event.
    public mutating func reset() {
        clearProgress()
        lastSeen = nil
    }

    private func matches(_ pose: HandPose) -> Bool {
        let reading = classifier.classify(pose)
        guard isActive, configuration.shape == .pinch else { return reading.shape == configuration.shape }
        guard let distance = reading.pinchDistance else { return false }
        return distance <= configuration.pinchReleaseDistance && classifier.indexIsFree(reading.fingerExtension)
    }

    private mutating func advance(with pose: HandPose, matches: Bool) -> HandGestureEvent? {
        if isActive {
            guard !matches else {
                missingFrames = 0
                lastMatch = pose
                return .changed(pose)
            }
            missingFrames = min(missingFrames + 1, configuration.framesToEnd)
            guard missingFrames >= configuration.framesToEnd else { return nil }
            let releasePose = lastMatch ?? pose
            clearProgress()
            return .ended(releasePose)
        }
        guard matches else {
            matchingFrames = 0
            return nil
        }
        matchingFrames = min(matchingFrames + 1, configuration.framesToBegin)
        guard matchingFrames >= configuration.framesToBegin else { return nil }
        isActive = true
        missingFrames = 0
        lastMatch = pose
        return .began(pose)
    }

    private mutating func clearProgress() {
        isActive = false
        matchingFrames = 0
        missingFrames = 0
        lastMatch = nil
    }
}
