import ClaudeKit
import Foundation
import LauncherKit

/// The AI tool's settings in the search bar: the shortcut that starts and stops listening, where a prompt said by voice is shown once sent, where speech that names no session goes, the phrases that name one, and whether Anvil found Claude Code, and where, since every chat runs through it.
enum AICatalog {
    private static let installHint = "Install Claude Code from claude.com/claude-code to chat from the search bar."

    static func settings(systemShortcuts: Set<KeyCombo>) -> [Setting] {
        let command = ClaudeCommand.url
        return Setting.subgroup("Listening", [listenShortcut(systemShortcuts: systemShortcuts), afterSending, unnamedSpeech] + SpokenPhrase.allCases.map(phraseRow))
            + Setting.subgroup("Claude Code", [
                .info("Claude Code", id: "ai.claudeCommand", toolName: Tool.ai.name, subtitle: command?.path ?? installHint, value: command == nil ? "Not found" : "Found", keywords: ["claude"]),
            ])
    }

    private static var afterSending: Setting {
        let choices = AfterSending.allCases
        return Setting(
            entry: SettingEntry(id: "ai.afterSending", title: "Show what was sent in", toolName: Tool.ai.name, keywords: ["voice", "pin", "claude desktop"]),
            row: .choice(selected: choices.firstIndex(of: .current) ?? 0, options: choices.map(\.name), pick: { AfterSending.current = choices[$0] })
        )
    }

    private static var unnamedSpeech: Setting {
        let choices = SpokenPrompt.Session.allCases
        return Setting(
            entry: SettingEntry(id: "ai.unnamedSession", title: "Speech that names no session goes to", toolName: Tool.ai.name, keywords: ["voice", "new session", "last session"]),
            row: .choice(selected: choices.firstIndex(of: UnnamedSpeech.session) ?? 0, options: choices.map(name), pick: { UnnamedSpeech.session = choices[$0] })
        )
    }

    private static func name(of session: SpokenPrompt.Session) -> String {
        switch session {
        case .new: "A new session"
        case .last: "The last session"
        }
    }

    private static func phraseRow(_ phrase: SpokenPhrase) -> Setting {
        .action(phrase.title, id: "ai.phrase.\(phrase)", toolName: Tool.ai.name, subtitle: "\u{201C}\(phrase.current)\u{201D}", actionTitle: "Edit") {
            SearchBar.shared.showPhraseForm(phrase)
            return nil
        }
    }

    private static func listenShortcut(systemShortcuts: Set<KeyCombo>) -> Setting {
        let combo = AIKeys.shared.listenCombo
        let clashes = Tool.ai.clashes(with: Shortcut(combo: combo, action: "Start or Stop Listening"), systemShortcuts: systemShortcuts)
        return .shortcut("Start or stop listening", id: "ai.listenShortcut", toolName: Tool.ai.name, combo: combo, canClear: false, clashes: clashes) { combo in
            if let combo { AIKeys.shared.setListenCombo(combo) }
        }
    }
}
