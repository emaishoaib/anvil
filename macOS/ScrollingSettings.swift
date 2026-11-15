import MouseKit

nonisolated enum ScrollingSettings {
    static let durationFramesRange = 2.0...60
    static let pointsPerTickRange = 10.0...300
    static let accelerationRange = 0.0...1

    static func milliseconds(frames: Double) -> Int {
        Int((frames * 1000 / ScrollSettings.framesPerSecond).rounded())
    }
}
