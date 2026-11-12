import SwiftUI

struct AnvilMenu: View {
    var body: some View {
        Button("Quit Anvil") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
