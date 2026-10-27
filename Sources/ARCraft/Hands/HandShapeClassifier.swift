import simd

/// A static hand shape that ``HandShapeClassifier`` recognizes.
public enum HandShape: String, CaseIterable, Codable, Sendable, Hashable {
    /// Thumb tip touching the index fingertip.
    case pinch
    /// Index finger extended, the other three fingers curled.
    case point
    /// All four fingers curled.
    case fist
    /// All four fingers extended.
    case openPalm
    /// None of the shapes above, or not enough joints tracked to tell.
    case other
}

/// What the classifier measured in one frame, and the shape it chose.
public struct HandShapeReading: Sendable, Hashable {
    /// The recognized shape.
    public var shape: HandShape
    /// Thumb tip to index fingertip, divided by the palm length; `nil` when either tip is missing.
    /// About 0.1 while pinching and 0.8 or more with the hand open.
    public var pinchDistance: Float?
    /// For each finger: wrist-to-tip distance divided by wrist-to-knuckle distance. About 1.8 for
    /// an extended finger and below 1 for a curled one. The thumb is not measured.
    public var fingerExtension: [Finger: Float]
}

/// Classifies a ``HandPose`` as a pinch, point, fist or open palm.
///
/// Every measure is a ratio of two distances on the same hand, so the thresholds work for small
/// and large hands, in meters (ARKit) and in pixels (Vision), and do not depend on where the hand
/// is. The classifier looks at a single frame; use ``HandGestureRecognizer`` for began, changed
/// and ended events that do not flicker.
public struct HandShapeClassifier: Sendable, Hashable {
    /// The thresholds the classifier uses.
    public struct Configuration: Sendable, Hashable {
        /// A pinch is recognized at or below this normalized thumb-to-index distance.
        public var pinchDistance: Float
        /// A finger counts as extended at or above this extension ratio.
        public var extendedRatio: Float
        /// A finger counts as curled at or below this extension ratio.
        public var curledRatio: Float

        /// Creates a configuration. Non-finite or non-positive values fall back to the defaults,
        /// and `curledRatio` is kept below `extendedRatio`.
        public init(pinchDistance: Float = 0.25, extendedRatio: Float = 1.5, curledRatio: Float = 1.2) {
            let valid = { (value: Float, fallback: Float) in value.isFinite && value > 0 ? value : fallback }
            self.pinchDistance = valid(pinchDistance, 0.25)
            self.extendedRatio = valid(extendedRatio, 1.5)
            self.curledRatio = min(valid(curledRatio, 1.2), self.extendedRatio)
        }
    }

    /// The thresholds in use.
    public var configuration: Configuration

    /// Creates a classifier.
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    /// The palm length used to normalize distances: wrist to middle knuckle, or wrist to index
    /// knuckle when the middle knuckle is not tracked. `nil` when neither is available.
    public static func palmLength(of pose: HandPose) -> Float? {
        let length = pose.distance(from: .wrist, to: .middleFingerKnuckle)
            ?? pose.distance(from: .wrist, to: .indexFingerKnuckle)
        guard let length, length.isFinite, length > SpatialMath.epsilon else { return nil }
        return length
    }

    /// Measures `pose` and picks a shape.
    public func classify(_ pose: HandPose) -> HandShapeReading {
        let fingerExtension = Self.fingerExtension(of: pose)
        let pinchDistance = Self.pinchDistance(of: pose)
        let shape = shape(pinchDistance: pinchDistance, fingerExtension: fingerExtension)
        return HandShapeReading(shape: shape, pinchDistance: pinchDistance, fingerExtension: fingerExtension)
    }

    /// `true` when the index finger is bent less than a curled finger, which separates a pinch
    /// from a fist whose thumb happens to rest near the index fingertip.
    func indexIsFree(_ fingerExtension: [Finger: Float]) -> Bool {
        guard let index = fingerExtension[.index] else { return false }
        return index > configuration.curledRatio
    }

    private func shape(pinchDistance: Float?, fingerExtension: [Finger: Float]) -> HandShape {
        if let pinchDistance, pinchDistance <= configuration.pinchDistance, indexIsFree(fingerExtension) {
            return .pinch
        }
        let ratios = Finger.fingers.map { fingerExtension[$0] }
        guard ratios.allSatisfy({ $0 != nil }) else { return .other }
        let values = ratios.compactMap { $0 }
        let curled = values.map { $0 <= configuration.curledRatio }
        let extended = values.map { $0 >= configuration.extendedRatio }
        if curled.allSatisfy({ $0 }) { return .fist }
        if extended.allSatisfy({ $0 }) { return .openPalm }
        if extended[0], curled.dropFirst().allSatisfy({ $0 }) { return .point }
        return .other
    }

    static func pinchDistance(of pose: HandPose) -> Float? {
        guard let palm = palmLength(of: pose),
              let distance = pose.distance(from: .thumbTip, to: .indexFingerTip) else { return nil }
        return distance / palm
    }

    static func fingerExtension(of pose: HandPose) -> [Finger: Float] {
        var result: [Finger: Float] = [:]
        for finger in Finger.fingers {
            guard let reach = pose.distance(from: .wrist, to: finger.tip),
                  let base = pose.distance(from: .wrist, to: finger.knuckle),
                  base > SpatialMath.epsilon else { continue }
            result[finger] = reach / base
        }
        return result
    }
}
