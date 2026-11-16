import Foundation

/// The arguments that start Claude Code as a chat another app drives. Prompts go in and events come out as stream JSON, one per line, and the answer streams in word by word. A new chat is saved under the given session id, so it can be found again, and a resumed chat carries on from that session's earlier turns under the same id. Whenever the permission mode needs an approval, Claude Code asks the app, which answers with an approval line.
public enum ClaudeArguments {
    public static func chat(sessionID: UUID, mode: PermissionMode) -> [String] {
        ["--session-id", sessionID.uuidString.lowercased()] + shared(mode: mode)
    }

    public static func resume(sessionID: UUID, mode: PermissionMode) -> [String] {
        ["--resume", sessionID.uuidString.lowercased()] + shared(mode: mode)
    }

    private static func shared(mode: PermissionMode) -> [String] {
        [
            "--print",
            "--input-format", "stream-json",
            "--output-format", "stream-json",
            "--verbose",
            "--include-partial-messages",
            "--permission-mode", mode.rawValue,
            "--permission-prompts", "host",
        ]
    }
}
