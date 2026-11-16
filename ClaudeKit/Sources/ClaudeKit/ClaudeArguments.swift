import Foundation

/// The arguments that start Claude Code as a chat another app drives. Prompts go in and events come out as stream JSON, one per line, and the answer streams in word by word. The chat is saved under the given session id, so it can be found again. Anything that would need an approval is turned down for now, because nothing answers approvals yet.
public enum ClaudeArguments {
    public static func chat(sessionID: UUID, mode: PermissionMode) -> [String] {
        [
            "--print",
            "--input-format", "stream-json",
            "--output-format", "stream-json",
            "--verbose",
            "--include-partial-messages",
            "--session-id", sessionID.uuidString.lowercased(),
            "--permission-mode", mode.rawValue,
            "--permission-prompts", "none",
        ]
    }
}
