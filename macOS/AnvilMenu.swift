import SwiftUI

struct AnvilMenu: View {
    @Environment(\.openWindow) private var openWindow
    @AppStorage(Tool.keepAwake.isOnKey) private var usesKeepAwake = false

    var body: some View {
        if usesKeepAwake {
            Toggle("Keep Awake", isOn: Binding(get: { KeepAwake.shared.isActive }, set: { KeepAwake.shared.setActive($0) }))
            Divider()
        }
        Button("Settings…") {
            openWindow(id: WindowID.settings)
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
