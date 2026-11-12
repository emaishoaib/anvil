import SwiftUI

@main
struct AnvilApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

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

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if !DEBUG
        LoginItem.addOnFirstLaunch()
        #endif
    }
}

enum WindowID {
    static let settings = "settings"
}
