import SwiftUI

struct AnvilMenu: View {
    var body: some View {
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
        Image(.menuBarIcon)
            .accessibilityLabel("Anvil")
    }
}
