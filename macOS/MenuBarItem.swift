import AppKit

/// Anvil's icon in the menu bar and the small menu it opens, with Check for Updates and Quit. It is a plain AppKit status item rather than a SwiftUI menu bar extra, so that the icon's layer can be animated.
final class MenuBarItem: NSObject, NSMenuDelegate {
    static let shared = MenuBarItem()

    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let checkForUpdates = NSMenuItem(title: "Check for Updates…", action: #selector(checkForUpdatesChosen), keyEquivalent: "")

    func start() {
        guard let button = item.button else { return }
        let icon = NSImage(resource: .menuBarIcon)
        icon.accessibilityDescription = "Anvil"
        button.image = icon
        item.menu = makeMenu()
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
        menu.items = [checkForUpdates, .separator(), quit]
        return menu
    }

    @objc private func checkForUpdatesChosen() {
        AppUpdater.shared.check()
    }
}
