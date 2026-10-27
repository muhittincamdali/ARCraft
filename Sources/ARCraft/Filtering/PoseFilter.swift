import Foundation
import simd

/// Smooths a stream of ``Pose`` values: a ``OneEuroFilter`` for the position and the same
/// speed-adaptive rule, applied with spherical interpolation, for the orientation.
///
/// Use it for anything that should follow a tracked pose without trembling: a menu attached to
/// the wrist, a cursor on the index fingertip, content attached to a world anchor.
///
/// ```swift
/// var wristFilter = PoseFilter(position: .handJoints, orientation: .handJoints)
/// if let pose = Pose(matrix: wristTransform), let smoothed = wristFilter.filter(pose, at: timestamp) {
///     palmMenu.transform = Transform(matrix: smoothed.matrix)
/// }
/// ```
public struct PoseFilter: Sendable {
    private var positionFilter: OneEuroFilter<SIMD3<Float>>
    private let orientationConfiguration: OneEuroConfiguration
    private var orientation: simd_quatf?
    private var angularSpeed: Float = 0
    private var timestamp: TimeInterval?

    /// The last smoothed pose, or `nil` before the first valid sample.
    public var pose: Pose? {
        guard let position = positionFilter.value, let orientation else { return nil }
        return Pose(position: position, orientation: orientation)
    }

    /// Creates a filter. The orientation configuration reads speed in radians per second.
    public init(position: OneEuroConfiguration = .anchors, orientation: OneEuroConfiguration = .anchors) {
        positionFilter = OneEuroFilter(configuration: position)
        orientationConfiguration = orientation
    }

    /// Smooths `sample`, taken at `time` seconds. Non-finite samples and timestamps that do not
    /// move forward are ignored and the previous pose is returned.
    public mutating func filter(_ sample: Pose, at time: TimeInterval) -> Pose? {
        guard time.isFinite, sample.isFinite else { return pose }
        guard let previous = orientation, let previousTime = timestamp else {
            return start(with: sample, at: time)
        }
        let elapsed = time - previousTime
        guard elapsed > 0 else { return pose }
        guard elapsed <= orientationConfiguration.resetInterval else {
            return start(with: sample, at: time)
        }
        _ = positionFilter.filter(sample.position, at: time)
        orientation = smoothedOrientation(from: previous, toward: sample.orientation, interval: Float(elapsed))
        timestamp = time
        return pose
    }

    /// Forgets the history; the next sample is passed through unchanged.
    public mutating func reset() {
        positionFilter.reset()
        orientation = nil
        angularSpeed = 0
        timestamp = nil
    }

    private mutating func start(with sample: Pose, at time: TimeInterval) -> Pose? {
        positionFilter.reset()
        _ = positionFilter.filter(sample.position, at: time)
        orientation = sample.orientation
        angularSpeed = 0
        timestamp = time
        return pose
    }

    private mutating func smoothedOrientation(from previous: simd_quatf, toward target: simd_quatf, interval: Float) -> simd_quatf {
        // q and -q are the same rotation; interpolate along the shorter arc.
        let target = simd_dot(previous.vector, target.vector) < 0 ? simd_quatf(vector: -target.vector) : target
        let rawSpeed = SpatialMath.angle(between: previous, and: target) / interval
        let speedFactor = OneEuroConfiguration.smoothingFactor(cutoff: orientationConfiguration.derivativeCutoff, interval: interval)
        angularSpeed += speedFactor * (rawSpeed - angularSpeed)
        if !angularSpeed.isFinite { angularSpeed = 0 }
        let cutoff = orientationConfiguration.minimumCutoff + orientationConfiguration.speedCoefficient * angularSpeed
        let factor = OneEuroConfiguration.smoothingFactor(cutoff: cutoff, interval: interval)
        return simd_normalize(simd_slerp(previous, target, factor))
    }
}
