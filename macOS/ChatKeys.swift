import AppKit
import Carbon.HIToolbox

/// The keys a chat answers wherever it is shown. While the chat is being renamed, Return keeps the name and Escape drops it. While skills are offered after a slash, the arrows move through them, Return or Tab puts one in the prompt and Escape closes the list. A question card's buttons move with left and right and Return presses one, and Escape denies an approval. Shift Return starts a new line in the prompt, and up and down move through its lines. Return signs Claude Code in when it is signed out and updates it when it is too old, and Escape cancels either. Escape stops an answer, leaves the chat or goes back to chatting from the leave question, and Command S saves the chat, or saves and leaves from that question. Before the first prompt, Command O picks the folder and Shift Tab the permission mode. Otherwise Return sends the prompt.
enum ChatKeys {
    enum Outcome {
        case handled
        case leftToField
        case notForChat
    }

    static func handle(_ keyCode: Int, modifiers: NSEvent.ModifierFlags, in chat: ChatModel, editor: NSTextView?, chooseFolder: () -> Void) -> Outcome {
        if chat.nameDraft != nil { return renaming(keyCode, in: chat) ? .handled : .leftToField }
        if chat.slashCommands.isShowing, slashCommand(keyCode, modifiers: modifiers, in: chat) { return .handled }
        if card(keyCode, in: chat) { return .handled }
        if chat.state == .awaitingApproval, keyCode == kVK_Escape {
            chat.choose(.deny)
            return .handled
        }
        if keyCode == kVK_Return, modifiers.contains(.shift), let editor {
            editor.insertNewlineIgnoringFieldEditor(nil)
            return .handled
        }
        if keyCode == kVK_UpArrow || keyCode == kVK_DownArrow { return .leftToField }
        if signIn(keyCode, in: chat) || update(keyCode, in: chat) || ending(keyCode, modifiers: modifiers, in: chat) { return .handled }
        if chat.session?.mode == nil, setup(keyCode, modifiers: modifiers, in: chat, chooseFolder: chooseFolder) { return .handled }
        if keyCode == kVK_Return || keyCode == kVK_ANSI_KeypadEnter, modifiers.intersection([.command, .option, .control]).isEmpty {
            chat.sendPrompt()
            return .handled
        }
        return .notForChat
    }

    private static func onlyCommand(in modifiers: NSEvent.ModifierFlags) -> Bool {
        modifiers.intersection([.command, .shift, .option, .control]) == .command
    }

    private static func renaming(_ keyCode: Int, in chat: ChatModel) -> Bool {
        switch keyCode {
        case kVK_Return, kVK_ANSI_KeypadEnter: chat.rename()
        case kVK_Escape: chat.cancelRenaming()
        default: return false
        }
        return true
    }

    private static func slashCommand(_ keyCode: Int, modifiers: NSEvent.ModifierFlags, in chat: ChatModel) -> Bool {
        guard modifiers.intersection([.command, .shift, .option, .control]).isEmpty else { return false }
        switch keyCode {
        case kVK_UpArrow: chat.slashCommands.moveSelection(by: -1)
        case kVK_DownArrow: chat.slashCommands.moveSelection(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter, kVK_Tab: chat.completeSlashCommand()
        case kVK_Escape: chat.dismissSlashCommands()
        default: return false
        }
        return true
    }

    private static func card(_ keyCode: Int, in chat: ChatModel) -> Bool {
        switch keyCode {
        case kVK_LeftArrow: chat.moveCardChoice(by: -1)
        case kVK_RightArrow: chat.moveCardChoice(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: chat.chooseCardChoice()
        default: false
        }
    }

    private static func signIn(_ keyCode: Int, in chat: ChatModel) -> Bool {
        switch (chat.state, keyCode) {
        case (.signedOut, kVK_Return), (.signedOut, kVK_ANSI_KeypadEnter): chat.signInToClaude()
        case (.signingIn, kVK_Escape): chat.signIn.cancel()
        default: return false
        }
        return true
    }

    private static func update(_ keyCode: Int, in chat: ChatModel) -> Bool {
        switch (chat.state, keyCode) {
        case (.outdated, kVK_Return), (.outdated, kVK_ANSI_KeypadEnter): chat.updateClaude()
        case (.updating, kVK_Escape): chat.update.cancel()
        default: return false
        }
        return true
    }

    private static func ending(_ keyCode: Int, modifiers: NSEvent.ModifierFlags, in chat: ChatModel) -> Bool {
        switch (chat.state, keyCode) {
        case (.answering, kVK_Escape): chat.stop()
        case (.started, kVK_Escape), (.outdated, kVK_Escape): chat.leave()
        case (.askingToLeave, kVK_Escape): chat.keepChatting()
        case (.askingToLeave, kVK_ANSI_S) where onlyCommand(in: modifiers): chat.save()
        case (.notStarted, kVK_ANSI_S), (.started, kVK_ANSI_S), (.answering, kVK_ANSI_S):
            guard onlyCommand(in: modifiers) else { return false }
            chat.startSaving()
        default: return false
        }
        return true
    }

    private static func setup(_ keyCode: Int, modifiers: NSEvent.ModifierFlags, in chat: ChatModel, chooseFolder: () -> Void) -> Bool {
        let shortcut = modifiers.intersection([.command, .shift, .option, .control])
        switch (keyCode, shortcut) {
        case (kVK_ANSI_O, .command):
            guard !chat.isStarted else { return false }
            chooseFolder()
        case (kVK_Tab, .shift): chat.setup.useNextMode()
        default: return false
        }
        return true
    }
}
