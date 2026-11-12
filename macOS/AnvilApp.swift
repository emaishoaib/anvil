import SwiftUI

@main
struct AnvilApp: App {
    var body: some Scene {
        MenuBarExtra("Anvil", image: .menuBarIcon) {
            AnvilMenu()
        }
    }
}
