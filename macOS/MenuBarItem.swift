import AppKit

/// Anvil's icon in the menu bar and the small menu it opens, with a greyed line saying what Anvil is doing while it works, Check for Updates and Quit. It is a plain AppKit status item rather than a SwiftUI menu bar extra, so that the icon's layer can be animated: it strikes as the search bar opens, and glows while Anvil sets up Logitech devices.
final class MenuBarItem: NSObject, NSMenuDelegate {
    static let shared = MenuBarItem()

    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let checkForUpdates = NSMenuItem(title: "Check for Updates…", action: #selector(checkForUpdatesChosen), keyEquivalent: "")
    private let activity = NSMenuItem(title: "Setting up Logitech devices…", action: nil, keyEquivalent: "")
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
            for await isBusy in Observations({ LogitechDevices.shared.isBusy }) {
                heat.set(isBusy)
                showActivity(isBusy)
            }
        }
    }

    /// Plays the strike on the icon, as the search bar opens.
    func strike() {
        guard let button = item.button else { return }
        StrikeAnimation.play(on: button)
    }

    /// Shows the activity line and the separator under it only while Anvil is busy, so an idle Anvil's menu has neither.
    private func showActivity(_ isBusy: Bool) {
        activity.isHidden = !isBusy
        activitySeparator.isHidden = !isBusy
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
        showActivity(false)
        menu.items = [activity, activitySeparator, checkForUpdates, .separator(), quit]
        return menu
    }

    @objc private func checkForUpdatesChosen() {
        AppUpdater.shared.check()
    }
}
