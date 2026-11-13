import IOKit.pwr_mgt
import Observation

@Observable
final class KeepAwake {
    static let shared = KeepAwake()

    private(set) var assertion: IOPMAssertionID?

    var isActive: Bool { assertion != nil }

    func setActive(_ isActive: Bool) {
        isActive ? start() : stop()
    }

    func start() {
        guard assertion == nil else { return }
        var id = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Anvil is keeping the Mac awake" as CFString,
            &id
        )
        guard result == kIOReturnSuccess else { return }
        assertion = id
    }

    func stop() {
        guard let assertion else { return }
        IOPMAssertionRelease(assertion)
        self.assertion = nil
    }
}
