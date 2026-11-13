import AppKit

enum MediaKeySender {
    private static let systemDefinedMediaKeySubtype: Int16 = 8
    private static let playKey = 16
    private static let keyDownState = 0xA
    private static let keyUpState = 0xB

    static func playOrPause() {
        for state in [keyDownState, keyUpState] {
            let event = NSEvent.otherEvent(
                with: .systemDefined,
                location: .zero,
                modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(state << 8)),
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                subtype: systemDefinedMediaKeySubtype,
                data1: playKey << 16 | state << 8,
                data2: -1
            )
            event?.cgEvent?.post(tap: .cghidEventTap)
        }
    }
}
