import SwiftUI

@main
struct AnvilApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            AnvilMenu()
        } label: {
            AnvilMenuIcon()
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
        KeepAwake.shared.restore()
        AppCatalog.shared.start()
        CurrencyRatesStore.shared.start()
        AppUpdater.shared.start()
        #if !DEBUG
        LoginItem.addOnFirstLaunch()
        #endif
        CGRequestScreenCaptureAccess()
        Task {
            await Accessibility.waitUntilTrusted()
            RuleKeys.shared.start()
            AppRules.start()
            KeySwapLibrary.shared.start()
            SettingsFolder.shared.start()
            MouseSettingsLibrary.shared.start()
            Keyboard.shared.start()
            MouseWheel.shared.start()
            LogitechDevices.shared.start()
            Recents.shared.start()
            KnownWindows.shared.start()
            Watcher.shared.start()
            DragSnapping.shared.start()
            TitleBarClicks.shared.start()
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard KeepAwake.shared.staysAwakeWithLidClosed else { return .terminateNow }
        Task {
            await KeepAwake.shared.stop()
            sender.reply(toApplicationShouldTerminate: !KeepAwake.shared.staysAwakeWithLidClosed)
        }
        return .terminateLater
    }
}

enum WindowID {
    static let settings = "settings"
}
