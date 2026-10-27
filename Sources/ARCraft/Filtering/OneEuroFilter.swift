import Foundation
import simd

/// The settings of a ``OneEuroFilter``.
///
/// The filter smooths heavily while a value is still (removing jitter) and lightly while it moves
/// fast (removing lag). `minimumCutoff` sets how much jitter is removed at rest; lower is smoother.
/// `speedCoefficient` sets how quickly smoothing drops as speed rises; higher means less lag.
public struct OneEuroConfiguration: Sendable, Hashable {
    /// The cutoff frequency in hertz while the value is still. Must be greater than zero.
    public var minimumCutoff: Float
    /// How much the cutoff rises per unit of speed (β in the paper). Zero or more.
    public var speedCoefficient: Float
    /// The cutoff frequency in hertz used to smooth the speed estimate. Must be greater than zero.
    public var derivativeCutoff: Float
    /// After this many seconds without a sample the filter forgets its history and restarts, so a
    /// hand that reappears elsewhere does not glide in from where it was lost.
    public var resetInterval: TimeInterval

    /// Creates a configuration. Values outside their valid range (zero, negative, NaN or
    /// infinite) are replaced with the defaults rather than producing a filter that emits NaN.
    public init(minimumCutoff: Float = 1, speedCoefficient: Float = 0.5,
                derivativeCutoff: Float = 1, resetInterval: TimeInterval = 0.5) {
        self.minimumCutoff = Self.positive(minimumCutoff, otherwise: 1)
        self.speedCoefficient = speedCoefficient.isFinite && speedCoefficient >= 0 ? speedCoefficient : 0.5
        self.derivativeCutoff = Self.positive(derivativeCutoff, otherwise: 1)
        self.resetInterval = resetInterval.isFinite && resetInterval > 0 ? resetInterval : 0.5
    }

    /// Tuned for hand joint positions in meters at 90 Hz: steady fingertips, little lag on fast moves.
    public static let handJoints = OneEuroConfiguration(minimumCutoff: 1.5, speedCoefficient: 8, derivativeCutoff: 1)

    /// Tuned for anchor and head positions in meters, which jitter by millimeters and move slowly.
    public static let anchors = OneEuroConfiguration(minimumCutoff: 0.5, speedCoefficient: 2, derivativeCutoff: 1, resetInterval: 2)

    private static func positive(_ value: Float, otherwise fallback: Float) -> Float {
        value.isFinite && value > 0 ? value : fallback
    }

    /// The exponential smoothing factor for a cutoff frequency and a sample interval.
    static func smoothingFactor(cutoff: Float, interval: Float) -> Float {
        let timeConstant = 1 / (2 * Float.pi * cutoff)
        return 1 / (1 + timeConstant / interval)
    }
}

/// A One Euro filter (Casiez, Roussel and Vogel, CHI 2012) for vectors of `Float`.
///
/// Feed it every sample with its timestamp; it returns the smoothed value. Use `SIMD3<Float>` for
/// positions and `SIMD2<Float>` for screen points.
///
/// ```swift
/// var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
/// if let smoothed = filter.filter(indexTip, at: timestamp) {
///     cursor.position = smoothed
/// }
/// ```
///
/// Samples are ignored, and the previous output is returned, when the value or the timestamp is
/// NaN or infinite or when the timestamp does not move forward. The result is `nil` only when no
/// valid sample has been seen yet.
public struct OneEuroFilter<Value: SIMD & Sendable>: Sendable where Value.Scalar == Float {
    /// The filter's settings.
    public let configuration: OneEuroConfiguration
    /// The last smoothed value, or `nil` before the first valid sample.
    public private(set) var value: Value?
    private var derivative = Value.zero
    private var timestamp: TimeInterval?

    /// Creates a filter with no history.
    public init(configuration: OneEuroConfiguration = OneEuroConfiguration()) {
        self.configuration = configuration
    }

    /// Smooths `sample`, taken at `time` seconds, and returns the filtered value.
    public mutating func filter(_ sample: Value, at time: TimeInterval) -> Value? {
        guard time.isFinite, Self.isFinite(sample) else { return value }
        guard let previous = value, let previousTime = timestamp else {
            start(with: sample, at: time)
            return sample
        }
        let elapsed = time - previousTime
        guard elapsed > 0 else { return previous }
        guard elapsed <= configuration.resetInterval else {
            start(with: sample, at: time)
            return sample
        }
        let interval = Float(elapsed)
        let rawDerivative = (sample - previous) / interval
        let derivativeFactor = OneEuroConfiguration.smoothingFactor(cutoff: configuration.derivativeCutoff, interval: interval)
        derivative = derivative + derivativeFactor * (rawDerivative - derivative)
        if !Self.isFinite(derivative) { derivative = .zero }
        let speed = (derivative * derivative).sum().squareRoot()
        let cutoff = configuration.minimumCutoff + configuration.speedCoefficient * speed
        let factor = OneEuroConfiguration.smoothingFactor(cutoff: cutoff, interval: interval)
        let smoothed = previous + factor * (sample - previous)
        guard Self.isFinite(smoothed) else {
            // Only reachable with values near Float.greatestFiniteMagnitude; start over.
            start(with: sample, at: time)
            return sample
        }
        value = smoothed
        timestamp = time
        return smoothed
    }

    /// Forgets the history; the next sample is passed through unchanged.
    public mutating func reset() {
        value = nil
        derivative = .zero
        timestamp = nil
    }

    private mutating func start(with sample: Value, at time: TimeInterval) {
        value = sample
        derivative = .zero
        timestamp = time
    }

    private static func isFinite(_ vector: Value) -> Bool {
        vector.indices.allSatisfy { vector[$0].isFinite }
    }
}
