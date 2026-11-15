import MouseKit

/// Turns a diverted thumb wheel's turns into the effect chosen in the mouse settings: sideways scrolling, up-and-down scrolling, or zooming with a pinch, at the chosen speed gain and direction. When scrolling, the part of a point left over from one message is carried into the next, so a slow turn still scrolls. Both the leftover and any pinch end when the turn stops.
enum ThumbWheelScroller {
    private static let pointsPerTurnUnit = 2.0
    private static let magnificationPerPoint = 0.005

    private static var leftoverPoints = 0.0
    private static var isPinching = false

    static func scroll(_ rotation: ThumbWheelRotation) {
        let settings = MouseSettingsLibrary.current
        let direction = settings.reversesThumbWheel ? -1.0 : 1.0
        let points = Double(rotation.amount) * pointsPerTurnUnit * settings.thumbWheelSpeedGain * direction
        let isStopping = rotation.phase == .stopping
        switch settings.thumbWheelEffect {
        case .scrollHorizontally:
            if let across = wholePoints(adding: points, isStopping: isStopping) { SmoothScroller.send(down: 0, across: across) }
        case .scrollVertically:
            if let down = wholePoints(adding: points, isStopping: isStopping) { SmoothScroller.send(down: down, across: 0) }
        case .zoom:
            pinch(points * magnificationPerPoint, isStopping: isStopping)
        }
    }

    private static func wholePoints(adding points: Double, isStopping: Bool) -> Int? {
        let total = leftoverPoints + points
        let whole = total.rounded(.towardZero)
        leftoverPoints = isStopping ? 0 : total - whole
        return whole == 0 ? nil : Int(whole)
    }

    private static func pinch(_ magnification: Double, isStopping: Bool) {
        if magnification != 0 {
            if !isPinching { PinchSender.send(0, phase: .began) }
            isPinching = true
            PinchSender.send(magnification, phase: .changed)
        }
        guard isStopping, isPinching else { return }
        PinchSender.send(0, phase: .ended)
        isPinching = false
    }
}
