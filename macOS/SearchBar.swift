import AppKit
import Carbon.HIToolbox
import LauncherKit
import SwiftUI

final class SearchBar {
    static let shared = SearchBar()

    private static let topShare = 0.25

    private let panel = SearchPanel()
    private var model = SearchModel()
    private var isPresentingModal = false

    func toggle() {
        panel.isVisible ? hide() : show()
    }

    func hide() {
        guard panel.isVisible, !isPresentingModal else { return }
        panel.orderOut(nil)
        if NSApp.isActive, NSApp.activationPolicy() == .accessory { NSApp.hide(nil) }
    }

    func presentModal<Result>(_ present: () -> Result) -> Result {
        isPresentingModal = true
        panel.level = .floating
        NSApp.activate()
        defer {
            isPresentingModal = false
            panel.level = .popUpMenu
            panel.makeKeyAndOrderFront(nil)
        }
        return present()
    }

    func fit(height: CGFloat) {
        guard panel.frame.height != height else { return }
        var frame = panel.frame
        frame.origin.y = frame.maxY - height
        frame.size.height = height
        panel.setFrame(frame, display: true)
    }

    func handleKey(_ keyCode: Int, modifiers: NSEvent.ModifierFlags) -> Bool {
        guard model.mode.hasSearchField else { return handleFormKey(keyCode, modifiers: modifiers) }
        guard model.actionPanel == nil else { return handleActionKey(keyCode, modifiers: modifiers) }
        if Self.onlyCommand(in: modifiers), keyCode == kVK_ANSI_K { return model.toggleActions() }
        if let action = QuickLinkAction.forShortcut(Self.combo(keyCode, modifiers)) { return model.run(action) }
        switch keyCode {
        case kVK_Tab: return model.moveFocus(by: modifiers.contains(.shift) ? -1 : 1)
        case kVK_UpArrow: model.moveSelection(by: -1)
        case kVK_DownArrow: model.moveSelection(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: model.openSelected()
        case kVK_Escape: if !model.leaveArguments(), !model.goBack() { hide() }
        case kVK_Delete: guard model.field == .query, model.query.isEmpty, model.goBack() else { return false }
        default: return false
        }
        return true
    }

    private static func onlyCommand(in modifiers: NSEvent.ModifierFlags) -> Bool {
        modifiers.intersection([.command, .shift, .option, .control]) == .command
    }

    private static func combo(_ keyCode: Int, _ modifiers: NSEvent.ModifierFlags) -> KeyCombo {
        KeyCombo(keyCode: keyCode, modifiers: KeyModifiers(eventFlags: modifiers))
    }

    private func handleActionKey(_ keyCode: Int, modifiers: NSEvent.ModifierFlags) -> Bool {
        if Self.onlyCommand(in: modifiers), keyCode == kVK_ANSI_K { return model.toggleActions() }
        if let action = QuickLinkAction.forShortcut(Self.combo(keyCode, modifiers)) { return model.run(action) }
        switch keyCode {
        case kVK_UpArrow: model.actionPanel?.moveSelection(by: -1)
        case kVK_DownArrow: model.actionPanel?.moveSelection(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: model.performSelectedAction()
        case kVK_Escape: model.backInActions()
        default: return false
        }
        return true
    }

    private func handleFormKey(_ keyCode: Int, modifiers: NSEvent.ModifierFlags) -> Bool {
        switch keyCode {
        case kVK_Return, kVK_ANSI_KeypadEnter:
            guard modifiers.contains(.command) else { return false }
            model.saveDraft()
        case kVK_Escape:
            _ = model.goBack()
        default:
            return false
        }
        return true
    }

    private func show() {
        guard let screen = NSScreen.main, let background = panel.contentView else { return }
        CurrencyRatesStore.shared.refreshIfStale()
        EntryWebView.warmUp()
        model = SearchModel()
        let content = NSHostingView(rootView: SearchBarView(model: model))
        let size = content.fittingSize
        let top = screen.frame.maxY - screen.frame.height * Self.topShare
        panel.setFrame(NSRect(x: screen.frame.midX - size.width / 2, y: top - size.height, width: size.width, height: size.height), display: true)
        content.frame = background.bounds
        content.autoresizingMask = [.width, .height]
        background.subviews.forEach { $0.removeFromSuperview() }
        background.addSubview(content)
        PanelAnimation.appear(panel)
        panel.makeKeyAndOrderFront(nil)
    }
}
