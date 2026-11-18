import Foundation
import LauncherKit

/// The AI tool's settings in the search bar: the shortcut that starts and stops listening, and whether Anvil found Claude Code, and where, since every chat runs through it.
enum AICatalog {
    private static let installHint = "Install Claude Code from claude.com/claude-code to chat from the search bar."

    static func settings(systemShortcuts: Set<KeyCombo>) -> [Setting] {
        let command = ClaudeCommand.url
        return Setting.subgroup("Listening", [listenShortcut(systemShortcuts: systemShortcuts)])
            + Setting.subgroup("Claude Code", [
                .info("Claude Code", id: "ai.claudeCommand", toolName: Tool.ai.name, subtitle: command?.path ?? installHint, value: command == nil ? "Not found" : "Found", keywords: ["claude"]),
            ])
    }

    private static func listenShortcut(systemShortcuts: Set<KeyCombo>) -> Setting {
        let combo = AIKeys.shared.listenCombo
        let clashes = Tool.ai.clashes(with: Shortcut(combo: combo, action: "Start or Stop Listening"), systemShortcuts: systemShortcuts)
        return .shortcut("Start or stop listening", id: "ai.listenShortcut", toolName: Tool.ai.name, combo: combo, canClear: false, clashes: clashes) { combo in
            if let combo { AIKeys.shared.setListenCombo(combo) }
        }
    }
}
