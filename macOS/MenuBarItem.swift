import AppKit

/// Anvil's icon in the menu bar and the small menu it opens, with a greyed line saying what Anvil is doing while it works, Check for Updates and Quit. It is a plain AppKit status item rather than a SwiftUI menu bar extra, so that the icon's layer can be animated: it strikes as the search bar opens, and glows while Anvil listens or sets up Logitech devices.
final class MenuBarItem: NSObject, NSMenuDelegate {
    static let shared = MenuBarItem()

    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let checkForUpdates = NSMenuItem(title: "Check for Updates…", action: #selector(checkForUpdatesChosen), keyEquivalent: "")
    private let activity = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let activitySeparator = NSMenuItem.separator()

    func start() {
        guard let button = item.button else { return }
        let icon = NSImage(resource: .menuBarIcon)
        icon.accessibilityDescription = "Anvil"
        button.image = icon
        button.wantsLayer = true
        item.menu = makeMenu()
        let heat = HeatAnimation(on: button)
        Task {
            for await activityTitle in Observations({ Self.activityTitle }) {
                heat.set(activityTitle != nil)
                showActivity(activityTitle)
            }
        }
    }

    /// Plays the strike on the icon, as the search bar opens.
    func strike() {
        guard let button = item.button else { return }
        StrikeAnimation.play(on: button)
    }

    /// What Anvil is doing, with listening first since it is what the glow most likely means, or nothing while Anvil is idle.
    private static var activityTitle: String? {
        if Listener.shared.isListening { return "Listening…" }
        if LogitechDevices.shared.isBusy { return "Setting up Logitech devices…" }
        return nil
    }

    /// Shows the activity line and the separator under it only while Anvil is busy, so an idle Anvil's menu has neither.
    private func showActivity(_ title: String?) {
        activity.title = title ?? ""
        activity.isHidden = title == nil
        activitySeparator.isHidden = title == nil
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        checkForUpdates.isEnabled = AppUpdater.shared.canCheck
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        checkForUpdates.target = self
        let quit = NSMenuItem(title: "Quit Anvil", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quit.target = NSApp
        activity.isEnabled = false
        showActivity(nil)
        menu.items = [activity, activitySeparator, checkForUpdates, .separator(), quit]
        return menu
    }

    @objc private func checkForUpdatesChosen() {
        AppUpdater.shared.check()
    }
}
