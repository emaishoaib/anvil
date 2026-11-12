import SwiftUI

struct AnvilMenu: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Settings…") {
            openWindow(id: WindowID.settings)
            NSApplication.shared.activate()
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
