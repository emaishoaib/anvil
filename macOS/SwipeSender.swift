import CoreGraphics
import RulesKit

nonisolated enum SwipeSender {
    private static let gestureType = CGEventType(rawValue: 29)
    private static let gestureKindField = CGEventField(rawValue: 110)
    private static let swipeField = CGEventField(rawValue: 115)
    private static let navigationSwipeGestureKind: Int64 = 16
    private static let swipeLeft: Int64 = 4
    private static let swipeRight: Int64 = 8

    static func send(_ direction: SwipeDirection) {
        guard let gestureType, let gestureKindField, let swipeField, let event = CGEvent(source: nil) else { return }
        event.type = gestureType
        event.flags = []
        event.setIntegerValueField(gestureKindField, value: navigationSwipeGestureKind)
        event.setIntegerValueField(swipeField, value: direction == .back ? swipeLeft : swipeRight)
        event.setIntegerValueField(.eventSourceUserData, value: KeySender.marker)
        event.post(tap: .cghidEventTap)
    }
}
