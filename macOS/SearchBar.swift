import AppKit
import Carbon.HIToolbox
import LauncherKit
import SwiftUI

final class SearchBar {
    static let shared = SearchBar()

    private let panel = SearchPanel()
    private let model = SearchModel()
    private lazy var content = NSHostingView(rootView: SearchBarView(model: model))
    private var isPresentingModal = false
    private var hiddenAt: ContinuousClock.Instant?
    private var collapsedFrame: NSRect?

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

    /// Hides the search bar, unless it is pinned. Unless told to forget, it is remembered as it was, so opening it again soon brings it back as it was, for as long as the search memory setting allows. A chat with Claude is always brought back, however long the bar was hidden, and keeps running while it is. So is AI mode while a sign-in waits on the browser, with the prompt still in the field.
    func hide(remembering: Bool = true) {
        guard panel.isVisible, !isPresentingModal, !model.isPinned else { return }
        model.settings.finishEditing()
        panel.orderOut(nil)
        hiddenAt = remembering ? .now : nil
        if NSApp.isActive { NSApp.hide(nil) }
    }

    private var remembersLastState: Bool {
        guard let hiddenAt else { return false }
        return ContinuousClock.now - hiddenAt < SearchMemory.current.duration
    }

    /// Sends what was said by voice to Claude, then shows the chat it went to where the after-sending setting says: in the bar in AI mode, pinned or not, or in Claude desktop. When the bar is needed to go on, it shows in the bar whatever the setting.
    func sendSpoken(_ said: String) {
        if !panel.isVisible { refreshModel() }
        guard model.sendSpoken(said) else { return }
        if AfterSending.current == .claudeDesktop, !model.needsBarAfterSpeaking {
            hide()
            return model.handOverToClaudeDesktop()
        }
        if !panel.isVisible { show(refreshingModel: false) }
        if AfterSending.current == .pinnedBar { model.pin() }
        panel.makeKeyAndOrderFront(nil)
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

    func showPhraseForm(_ phrase: SpokenPhrase) {
        model.showPhraseForm(phrase)
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

    /// Sizes the search bar to its content, keeping its top edge where it is. A change of width, such as leaving AI mode while it is expanded, puts the bar back in its usual place. An expanded bar is sized by the screen instead, so its content is not measured.
    func fit(_ size: CGSize) {
        guard !model.isExpanded else { return }
        collapsedFrame = nil
        guard panel.frame.size != size, let screen = panel.screen ?? NSScreen.main else { return }
        guard panel.frame.width == size.width else { return panel.setFrame(PanelResizing.usualFrame(for: size, on: screen), display: true) }
        var frame = panel.frame
        frame.origin.y = frame.maxY - size.height
        frame.size.height = size.height
        panel.setFrame(frame, display: true)
    }

    /// Grows the search bar to fill most of the screen in AI mode, or shrinks it back to where it was, animating either way.
    func toggleExpanded() {
        guard model.mode == .askClaude, let screen = panel.screen ?? NSScreen.main else { return }
        if let collapsedFrame {
            self.collapsedFrame = nil
            PanelResizing.animate(panel, to: collapsedFrame) { self.model.setExpanded(false) }
        } else {
            collapsedFrame = panel.frame
            model.setExpanded(true)
            PanelResizing.animate(panel, to: PanelResizing.expandedFrame(on: screen))
        }
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
        if model.mode == .settings, model.settings.isShowingGrid, keyCode == kVK_LeftArrow || keyCode == kVK_RightArrow {
            model.settings.moveAcross(by: keyCode == kVK_LeftArrow ? -1 : 1)
            return true
        }
        if Self.onlyCommand(in: modifiers), keyCode == kVK_ANSI_K { return model.toggleActions() }
        if Self.onlyCommand(in: modifiers), keyCode == kVK_Return || keyCode == kVK_ANSI_KeypadEnter, model.moveTickedToTrash() { return true }
        if Self.onlyCommand(in: modifiers), keyCode == kVK_ANSI_R, model.revealSelected() { return true }
        if model.mode == .askClaude, handleCardKey(keyCode) { return true }
        if model.mode == .askClaude, model.chatState == .awaitingApproval, keyCode == kVK_Escape {
            model.choose(.deny)
            return true
        }
        if model.mode == .askClaude, Self.onlyCommand(in: modifiers), keyCode == kVK_ANSI_E {
            toggleExpanded()
            return true
        }
        if model.mode == .askClaude, keyCode == kVK_Return, modifiers.contains(.shift), let editor = panel.firstResponder as? NSTextView {
            editor.insertNewlineIgnoringFieldEditor(nil)
            return true
        }
        if model.mode == .askClaude, handleSignInKey(keyCode) { return true }
        if model.mode == .askClaude, handleUpdateKey(keyCode) { return true }
        if model.mode == .askClaude, handleEndingKey(keyCode, modifiers: modifiers) { return true }
        if model.mode == .askClaude, model.chat?.mode == nil, handleChatSetupKey(keyCode, modifiers: modifiers) { return true }
        if let action = QuickLinkAction.forShortcut(Self.combo(keyCode, modifiers)) { return model.run(action) }
        if let action = AnvilAction.forShortcut(Self.combo(keyCode, modifiers)) {
            model.perform(.anvil(action))
            return true
        }
        if model.mode == .desktopSessions, keyCode == kVK_Tab, !modifiers.contains(.shift) {
            model.startChat()
            return true
        }
        switch keyCode {
        case kVK_Tab: return model.moveFocus(by: modifiers.contains(.shift) ? -1 : 1) || !modifiers.contains(.shift) && model.enterAIMode()
        case kVK_UpArrow: model.moveSelection(by: -1)
        case kVK_DownArrow: model.moveSelection(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: model.openSelected()
        case kVK_Escape: if !model.leaveArguments(), !model.goBack() { hide() }
        case kVK_Delete: guard model.field == .query, model.query.isEmpty, model.chat == nil, model.clearSelectedShortcut() || model.goBack() else { return false }
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

    private func handleCardKey(_ keyCode: Int) -> Bool {
        switch keyCode {
        case kVK_LeftArrow: model.moveCardChoice(by: -1)
        case kVK_RightArrow: model.moveCardChoice(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: model.chooseCardChoice()
        default: false
        }
    }

    private func handleEndingKey(_ keyCode: Int, modifiers: NSEvent.ModifierFlags) -> Bool {
        switch (model.chatState, keyCode) {
        case (.answering, kVK_Escape): model.chat?.stop()
        case (.started, kVK_Escape), (.outdated, kVK_Escape): model.leaveChat()
        case (.askingToLeave, kVK_Escape): model.keepChatting()
        case (.askingToLeave, kVK_ANSI_S) where Self.onlyCommand(in: modifiers): model.saveChat()
        case (.notStarted, kVK_ANSI_S), (.started, kVK_ANSI_S), (.answering, kVK_ANSI_S):
            guard Self.onlyCommand(in: modifiers) else { return false }
            model.startSavingChat()
        default: return false
        }
        return true
    }

    private func handleSignInKey(_ keyCode: Int) -> Bool {
        switch (model.chatState, keyCode) {
        case (.signedOut, kVK_Return), (.signedOut, kVK_ANSI_KeypadEnter): model.signInToClaude()
        case (.signingIn, kVK_Escape): model.claudeSignIn.cancel()
        default: return false
        }
        return true
    }

    private func handleUpdateKey(_ keyCode: Int) -> Bool {
        switch (model.chatState, keyCode) {
        case (.outdated, kVK_Return), (.outdated, kVK_ANSI_KeypadEnter): model.updateClaude()
        case (.updating, kVK_Escape): model.claudeUpdate.cancel()
        default: return false
        }
        return true
    }

    private func handleChatSetupKey(_ keyCode: Int, modifiers: NSEvent.ModifierFlags) -> Bool {
        let shortcut = modifiers.intersection([.command, .shift, .option, .control])
        switch (keyCode, shortcut) {
        case (kVK_ANSI_O, .command):
            guard model.chat == nil else { return false }
            presentModal(model.chatSetup.chooseFolder)
        case (kVK_Tab, .shift): model.chatSetup.useNextMode()
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
        case kVK_Tab:
            return model.moveQuickLinkFocus(by: modifiers.contains(.shift) ? -1 : 1)
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

    private func show(refreshingModel: Bool = true) {
        guard let screen = NSScreen.main else { return }
        CurrencyRatesStore.shared.refreshIfStale()
        if refreshingModel { refreshModel() }
        attachContent()
        content.layoutSubtreeIfNeeded()
        let frame = model.isExpanded ? PanelResizing.expandedFrame(on: screen) : PanelResizing.usualFrame(for: content.fittingSize, on: screen)
        panel.setFrame(frame, display: true)
        PanelAnimation.appear(panel)
        panel.makeKeyAndOrderFront(nil)
        MenuBarItem.shared.strike()
        AirPodsBatteries.shared.refresh()
    }

    /// Brings the bar back as it was when it was hidden only a moment ago or holds a chat, and otherwise starts it fresh.
    private func refreshModel() {
        if remembersLastState || model.isHoldingChat { model.reopen() } else { model.reset() }
    }
}
