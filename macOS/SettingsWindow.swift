import AppKit
import SwiftUI

/// The settings window, built once soon after launch and only hidden when closed, so choosing Settings never waits for it to be built.
final class SettingsWindow: NSObject, NSWindowDelegate {
    static let shared = SettingsWindow()

    private static let title = "Anvil"
    private static let frameName = "settings"
    private static let defaultSize = NSSize(width: 680, height: 460)

    private lazy var window = makeWindow()

    func prepare() {
        SettingsPages.shared.prepare()
        window.contentView?.layoutSubtreeIfNeeded()
    }

    func show() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    private func makeWindow() -> NSWindow {
        let content = NSHostingController(rootView: SettingsView())
        content.sizingOptions = []
        content.sceneBridgingOptions = .all
        let window = NSWindow(contentViewController: content)
        window.title = Self.title
        window.styleMask.insert(.fullSizeContentView)
        window.isReleasedWhenClosed = false
        window.animationBehavior = .none
        window.delegate = self
        window.setContentSize(Self.defaultSize)
        if !window.setFrameUsingName(Self.frameName) { window.center() }
        window.setFrameAutosaveName(Self.frameName)
        return window
    }
}
