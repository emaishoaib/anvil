import MouseKit

/// Turns a diverted thumb wheel's turns into sideways scrolling, at the speed gain and in the direction chosen in the mouse settings. The part of a point left over from one message is carried into the next, so a slow turn still scrolls, and it is dropped when the turn stops.
enum ThumbWheelScroller {
    private static let pointsPerTurnUnit = 2.0

    private static var leftoverPoints = 0.0

    static func scroll(_ rotation: ThumbWheelRotation) {
        let settings = MouseSettingsLibrary.current
        let direction = settings.reversesThumbWheel ? -1.0 : 1.0
        let points = leftoverPoints + Double(rotation.amount) * pointsPerTurnUnit * settings.thumbWheelSpeedGain * direction
        let wholePoints = points.rounded(.towardZero)
        leftoverPoints = rotation.phase == .stopping ? 0 : points - wholePoints
        guard wholePoints != 0 else { return }
        SmoothScroller.send(down: 0, across: Int(wholePoints))
    }
}
