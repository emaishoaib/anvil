import SwiftUI

struct AnvilMenu: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Settings…") {
            openWindow(id: WindowID.settings)
            NSApplication.shared.activate()
        }
        .keyboardShortcut(",")
        Divider()
        Button("Quit Anvil") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
