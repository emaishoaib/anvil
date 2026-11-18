import Foundation

@MainActor extension Tool {
    /// Turns the tool on or off, and brings the parts of Anvil that depend on it in line.
    func setOn(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: isOnKey)
        switch self {
        case .mouse: LogitechDevices.shared.applyMouseTool()
        case .keepAwake where !isOn: Task { await KeepAwake.shared.setActive(false) }
        case .shell: ShellLoading.set(isOn)
        default: break
        }
    }
}
