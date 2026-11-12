import SwiftUI

@main
struct AnvilApp: App {
    var body: some Scene {
        MenuBarExtra("Anvil", image: .menuBarIcon) {
            AnvilMenu()
        }
        Window("Anvil", id: WindowID.settings) {
            SettingsView()
        }
        .defaultSize(width: 680, height: 460)
        .defaultLaunchBehavior(.suppressed)
    }
}

enum WindowID {
    static let settings = "settings"
}
