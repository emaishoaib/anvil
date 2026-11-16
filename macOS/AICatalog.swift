import Foundation

/// The AI tool's settings in the search bar: whether Anvil found Claude Code, and where, since every chat runs through it.
enum AICatalog {
    private static let installHint = "Install Claude Code from claude.com/claude-code to chat from the search bar."

    static func settings() -> [Setting] {
        let command = ClaudeCommand.url
        return Setting.subgroup("Claude Code", [
            .info("Claude Code", id: "ai.claudeCommand", toolName: Tool.ai.name, subtitle: command?.path ?? installHint, value: command == nil ? "Not found" : "Found", keywords: ["claude"]),
        ])
    }
}
