import CoreGraphics

nonisolated enum PinchSender {
    enum Phase: Int64 {
        case began = 1, changed = 2, ended = 4
    }

    private static let gestureType = CGEventType(rawValue: 29)
    private static let gestureKindField = CGEventField(rawValue: 110)
    private static let magnificationField = CGEventField(rawValue: 113)
    private static let phaseField = CGEventField(rawValue: 132)
    private static let zoomGestureKind: Int64 = 8

    static func send(_ magnification: Double, phase: Phase) {
        guard let gestureType, let gestureKindField, let magnificationField, let phaseField,
              let event = CGEvent(source: nil)
        else { return }
        event.type = gestureType
        event.flags = []
        event.setIntegerValueField(gestureKindField, value: zoomGestureKind)
        event.setIntegerValueField(phaseField, value: phase.rawValue)
        event.setDoubleValueField(magnificationField, value: magnification)
        event.setIntegerValueField(.eventSourceUserData, value: KeySender.marker)
        event.post(tap: .cghidEventTap)
    }
}
