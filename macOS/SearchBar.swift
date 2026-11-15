import AppKit
import Carbon.HIToolbox
import LauncherKit
import SwiftUI

final class SearchBar {
    static let shared = SearchBar()

    private static let topShare = 0.25

    private let panel = SearchPanel()
    private let model = SearchModel()
    private lazy var content = NSHostingView(rootView: SearchBarView(model: model))
    private var isPresentingModal = false
    private var hiddenAt: ContinuousClock.Instant?

    var isPinned: Bool { model.isPinned }

    /// Catches up with changes made while the search bar did not have keyboard focus, such as files deleted in Finder.
    func tookFocus() {
        model.review?.dropMissingItems()
    }

    /// Shows the search bar, or hides it when it is showing. A pinned search bar cannot be hidden, so it takes the keyboard back instead.
    func toggle() {
        guard panel.isVisible else { return show() }
        model.isPinned ? panel.makeKeyAndOrderFront(nil) : hide()
    }

    /// Hides the search bar, unless it is pinned. Unless told to forget, it is remembered as it was, so opening it again soon brings it back as it was, for as long as the search memory setting allows.
    func hide(remembering: Bool = true) {
        guard panel.isVisible, !isPresentingModal, !model.isPinned else { return }
        model.settings.finishEditing()
        hiddenAt = remembering ? .now : nil
        panel.orderOut(nil)
        if NSApp.isActive { NSApp.hide(nil) }
    }

    private var remembersLastState: Bool {
        guard let hiddenAt else { return false }
        return ContinuousClock.now - hiddenAt < SearchMemory.current.duration
    }

    func showRuleForm(_ draft: RuleDraft, in group: RuleGroup, isNew: Bool) {
        model.showRuleForm(draft, in: group, isNew: isNew)
    }

    func refreshSettings() {
        model.settings.refresh()
    }

    func showKeySwapForm() {
        model.showKeySwapForm()
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
        model.settings.dismissMessage()
        if Self.onlyCommand(in: modifiers), keyCode == kVK_ANSI_P {
            model.togglePin()
            return true
        }
        guard model.mode.hasSearchField else { return handleFormKey(keyCode, modifiers: modifiers) }
        guard model.actionPanel == nil else { return handleActionKey(keyCode, modifiers: modifiers) }
        if model.mode == .settings, model.settings.isAdjusting { return handleAdjustingKey(keyCode) }
        if Self.onlyCommand(in: modifiers), keyCode == kVK_ANSI_K { return model.toggleActions() }
        if Self.onlyCommand(in: modifiers), keyCode == kVK_Return || keyCode == kVK_ANSI_KeypadEnter, model.moveTickedToTrash() { return true }
        if Self.onlyCommand(in: modifiers), keyCode == kVK_ANSI_R, model.revealSelected() { return true }
        if let action = QuickLinkAction.forShortcut(Self.combo(keyCode, modifiers)) { return model.run(action) }
        if let action = AnvilAction.forShortcut(Self.combo(keyCode, modifiers)) {
            model.perform(.anvil(action))
            return true
        }
        switch keyCode {
        case kVK_Tab: return model.moveFocus(by: modifiers.contains(.shift) ? -1 : 1)
        case kVK_UpArrow: model.moveSelection(by: -1)
        case kVK_DownArrow: model.moveSelection(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: model.openSelected()
        case kVK_Escape: if !model.leaveArguments(), !model.goBack() { hide() }
        case kVK_Delete: guard model.field == .query, model.query.isEmpty, model.clearSelectedShortcut() || model.goBack() else { return false }
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
        let combo = Self.combo(keyCode, modifiers)
        switch model.actionPanel?.subject {
        case .anvil:
            if let action = AnvilAction.forShortcut(combo) {
                model.perform(.anvil(action))
                return true
            }
        case .quickLink, nil:
            if let action = QuickLinkAction.forShortcut(combo) { return model.run(action) }
        case .rule:
            if let action = RuleRowAction.forShortcut(combo) {
                model.perform(.ruleAction(action))
                return true
            }
        case .settingChoices:
            break
        }
        switch keyCode {
        case kVK_UpArrow: model.actionPanel?.moveSelection(by: -1)
        case kVK_DownArrow: model.actionPanel?.moveSelection(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: model.performSelectedAction()
        case kVK_Escape: model.backInActions()
        default: return false
        }
        return true
    }

    private func handleAdjustingKey(_ keyCode: Int) -> Bool {
        switch keyCode {
        case kVK_LeftArrow: model.settings.step(by: -1)
        case kVK_RightArrow: model.settings.step(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter, kVK_Escape: model.settings.finishAdjusting()
        case kVK_UpArrow, kVK_DownArrow: break
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

    /// Builds the search bar's view and window once, invisibly, so the first time it opens is as quick as every time after. It does nothing once the bar has been built, such as when it was opened before this ran.
    func warmUp() {
        guard content.superview == nil else { return }
        attachContent()
        content.layoutSubtreeIfNeeded()
        panel.setContentSize(content.fittingSize)
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        panel.display()
        panel.orderOut(nil)
    }

    private func attachContent() {
        guard content.superview == nil, let background = panel.contentView else { return }
        content.frame = background.bounds
        content.autoresizingMask = [.width, .height]
        background.addSubview(content)
    }

    private func show() {
        guard let screen = NSScreen.main else { return }
        CurrencyRatesStore.shared.refreshIfStale()
        if remembersLastState { model.reopen() } else { model.reset() }
        attachContent()
        content.layoutSubtreeIfNeeded()
        let size = content.fittingSize
        let top = screen.frame.maxY - screen.frame.height * Self.topShare
        panel.setFrame(NSRect(x: screen.frame.midX - size.width / 2, y: top - size.height, width: size.width, height: size.height), display: true)
        PanelAnimation.appear(panel)
        panel.makeKeyAndOrderFront(nil)
        MenuBarItem.shared.strike()
        AirPodsBatteries.shared.refresh()
    }
}
