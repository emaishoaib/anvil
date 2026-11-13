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
        guard Tool.mouse.isOn, event.isFromMouseWheel else { return false }
        let settings = MouseSettingsLibrary.current
        if settings.reversesWheel { event.reverseVertically() }
        if settings.reversesThumbWheel { event.reverseHorizontally() }
        guard let ticks = event.verticalTicks, let effect = event.wheelEffect else { return false }
        let gain = event.flags.contains(.maskCommand) ? settings.commandScrollSpeed.gain : 1
        let seconds = CACurrentMediaTime()
        DispatchQueue.main.async { SmoothScroller.shared.add(ticks: ticks, for: effect, gain: gain, atSeconds: seconds) }
        return true
    }
}

private nonisolated extension CGEvent {
    static let modifiers: CGEventFlags = [.maskShift, .maskControl, .maskAlternate, .maskCommand]

    var isFromMouseWheel: Bool {
        getIntegerValueField(.scrollWheelEventIsContinuous) == 0
            && getIntegerValueField(.eventSourceUserData) != KeySender.marker
    }

    var wheelEffect: WheelEffect? {
        switch flags.intersection(Self.modifiers) {
        case [], .maskCommand: .scrollVertically
        case .maskShift: .scrollHorizontally
        case .maskControl: .zoom
        default: nil
        }
    }

    var verticalTicks: Int? {
        let delta = getIntegerValueField(.scrollWheelEventDeltaAxis1)
        guard delta != 0 else { return nil }
        return Int(delta.signum())
    }

    func reverseVertically() {
        negate(.scrollWheelEventDeltaAxis1, .scrollWheelEventPointDeltaAxis1, fixedPoint: .scrollWheelEventFixedPtDeltaAxis1)
    }

    func reverseHorizontally() {
        negate(.scrollWheelEventDeltaAxis2, .scrollWheelEventPointDeltaAxis2, fixedPoint: .scrollWheelEventFixedPtDeltaAxis2)
    }

    private func negate(_ lines: CGEventField, _ points: CGEventField, fixedPoint: CGEventField) {
        setIntegerValueField(lines, value: -getIntegerValueField(lines))
        setIntegerValueField(points, value: -getIntegerValueField(points))
        setDoubleValueField(fixedPoint, value: -getDoubleValueField(fixedPoint))
    }
}
