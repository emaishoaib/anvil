import AppKit
import os

nonisolated final class Keyboard: @unchecked Sendable {
    static let shared = Keyboard()

    private var tap: CFMachPort?
    private let shortcutsPaused = OSAllocatedUnfairLock(initialState: false)

    func pauseShortcuts(_ paused: Bool) {
        shortcutsPaused.withLock { $0 = paused }
    }

    func start() {
        let thread = Thread { [self] in
            let mask = CGEventMask(1 << CGEventType.keyDown.rawValue | 1 << CGEventType.flagsChanged.rawValue)
            tap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: mask,
                callback: { _, type, event, _ in
                    Keyboard.shared.handle(type, event) ? nil : Unmanaged.passUnretained(event)
                },
                userInfo: nil
            )
            guard let tap else { fatalError("Could not create the keyboard event tap") }
            CFRunLoopAddSource(CFRunLoopGetCurrent(), CFMachPortCreateRunLoopSource(nil, tap, 0), .commonModes)
            CFRunLoopRun()
        }
        thread.name = "Anvil keyboard"
        thread.qualityOfService = .userInteractive
        thread.start()
    }

    private func handle(_ type: CGEventType, _ event: CGEvent) -> Bool {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return false
        }
        guard !shortcutsPaused.withLock({ $0 }), let press = KeyPress(type, event) else { return false }
        let responders = Tool.allCases.filter(\.isOn).compactMap(\.keyResponder)
        return responders.contains { $0.respond(to: press) }
    }
}
