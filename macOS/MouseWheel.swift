import AppKit
import QuartzCore

nonisolated final class MouseWheel: @unchecked Sendable {
    static let shared = MouseWheel()

    private var tap: CFMachPort?

    func start() {
        let thread = Thread { [self] in
            tap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: CGEventMask(1 << CGEventType.scrollWheel.rawValue),
                callback: { _, type, event, _ in
                    MouseWheel.shared.handle(type, event) ? nil : Unmanaged.passUnretained(event)
                },
                userInfo: nil
            )
            guard let tap else { fatalError("Could not create the mouse wheel event tap") }
            CFRunLoopAddSource(CFRunLoopGetCurrent(), CFMachPortCreateRunLoopSource(nil, tap, 0), .commonModes)
            CFRunLoopRun()
        }
        thread.name = "Anvil mouse wheel"
        thread.qualityOfService = .userInteractive
        thread.start()
    }

    private func handle(_ type: CGEventType, _ event: CGEvent) -> Bool {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return false
        }
        guard Tool.mouse.isOn, let ticks = event.verticalWheelTicks else { return false }
        let seconds = CACurrentMediaTime()
        DispatchQueue.main.async { SmoothScroller.shared.add(ticks: ticks, atSeconds: seconds) }
        return true
    }
}

private nonisolated extension CGEvent {
    static let modifiersLeftToTheSystem: CGEventFlags = [.maskShift, .maskControl, .maskAlternate, .maskCommand]

    var verticalWheelTicks: Int? {
        guard getIntegerValueField(.scrollWheelEventIsContinuous) == 0,
              getIntegerValueField(.eventSourceUserData) != KeySender.marker,
              flags.intersection(Self.modifiersLeftToTheSystem).isEmpty
        else { return nil }
        let delta = getIntegerValueField(.scrollWheelEventDeltaAxis1)
        guard delta != 0 else { return nil }
        return Int(delta.signum())
    }
}
