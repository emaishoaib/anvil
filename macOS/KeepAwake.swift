import Foundation
import IOKit.pwr_mgt
import Observation

@Observable
final class KeepAwake {
    enum State {
        case off
        case awake(IOPMAssertionID, withLidClosed: Bool)
    }

    static let shared = KeepAwake()

    private static let isActiveKey = "keepAwake.isActive"

    private(set) var state = State.off

    var isActive: Bool {
        switch state {
        case .off: false
        case .awake: true
        }
    }

    var staysAwakeWithLidClosed: Bool {
        switch state {
        case .off: false
        case .awake(_, let withLidClosed): withLidClosed
        }
    }

    func restore() {
        guard Tool.keepAwake.isOn, UserDefaults.standard.bool(forKey: Self.isActiveKey) else { return }
        start()
    }

    func setActive(_ isActive: Bool) async {
        if isActive { start() } else { await stop() }
        UserDefaults.standard.set(self.isActive, forKey: Self.isActiveKey)
    }

    func start() {
        guard case .off = state else { return }
        var id = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Anvil is keeping the Mac awake" as CFString,
            &id
        )
        guard result == kIOReturnSuccess else { return }
        state = .awake(id, withLidClosed: false)
    }

    func stop() async {
        guard case .awake(_, let withLidClosed) = state else { return }
        if withLidClosed { guard await LidSleep.setDisabled(false) else { return } }
        guard case .awake(let assertion, _) = state else { return }
        IOPMAssertionRelease(assertion)
        state = .off
    }

    func setStaysAwakeWithLidClosed(_ withLidClosed: Bool) async {
        guard isActive, withLidClosed != staysAwakeWithLidClosed, await LidSleep.setDisabled(withLidClosed),
              case .awake(let assertion, _) = state else { return }
        state = .awake(assertion, withLidClosed: withLidClosed)
    }
}
