import SwiftUI

@main
struct AnvilApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Anvil", image: .menuBarIcon) {
            AnvilMenu()
        }
        SwiftUI.Window("Anvil", id: WindowID.settings) {
            SettingsView()
        }
        .defaultSize(width: 680, height: 460)
        .defaultLaunchBehavior(.suppressed)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Tool.registerDefaults()
        AppCatalog.shared.start()
        CurrencyRatesStore.shared.start()
        AppUpdater.shared.start()
        #if !DEBUG
        LoginItem.addOnFirstLaunch()
        #endif
        CGRequestScreenCaptureAccess()
        Task {
            await Accessibility.waitUntilTrusted()
            Keyboard.shared.start()
            Recents.shared.start()
            KnownWindows.shared.start()
            Watcher.shared.start()
            DragSnapping.shared.start()
            TitleBarClicks.shared.start()
        }
    }
}

enum WindowID {
    static let settings = "settings"
}
