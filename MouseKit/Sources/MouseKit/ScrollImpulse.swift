struct ScrollImpulse: Sendable {
    let startSeconds: Double
    let points: Double
    let durationSeconds: Double
    let brakeSeconds: Double

    var endSeconds: Double { startSeconds + durationSeconds }

    func position(atSeconds time: Double) -> Double {
        let elapsed = max(time - startSeconds, 0)
        guard elapsed < durationSeconds else { return points }
        let peakSpeed = 2 * points / (durationSeconds + brakeSeconds)
        guard elapsed > brakeSeconds else { return peakSpeed * elapsed }
        let braking = elapsed - brakeSeconds
        return peakSpeed * (elapsed - braking * braking / (2 * (durationSeconds - brakeSeconds)))
    }
}
