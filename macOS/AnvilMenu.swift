import SwiftUI

struct AnvilMenu: View {
    @AppStorage(Tool.keepAwake.isOnKey) private var usesKeepAwake = false

    var body: some View {
        if usesKeepAwake {
            Toggle("Keep Awake", isOn: Binding(
                get: { KeepAwake.shared.isActive },
                set: { isActive in Task { await KeepAwake.shared.setActive(isActive) } }
            ))
            Toggle("Stay Awake with Lid Closed", isOn: Binding(
                get: { KeepAwake.shared.staysAwakeWithLidClosed },
                set: { withLidClosed in Task { await KeepAwake.shared.setStaysAwakeWithLidClosed(withLidClosed) } }
            ))
            .disabled(!KeepAwake.shared.isActive)
            Divider()
        }
        Button("Settings…") {
            SettingsWindow.shared.show()
        }
        .keyboardShortcut(",")
        Button("Check for Updates…") {
            AppUpdater.shared.check()
        }
        .disabled(!AppUpdater.shared.canCheck)
        Divider()
        Button("Quit Anvil") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

struct AnvilMenuIcon: View {
    var body: some View {
        Image(KeepAwake.shared.isActive ? .menuBarIconAwake : .menuBarIcon)
            .accessibilityLabel("Anvil")
    }
}
