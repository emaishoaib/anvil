import Foundation

/// The files Claude Code keeps for one chat: its transcript, named after the session id, and the folder of the same name beside it when there is one. They sit in a folder per project under `~/.claude/projects`, so every project folder is looked in, since the session id alone is enough to find them.
nonisolated enum ClaudeSessionFiles {
    private static let projects = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".claude/projects")

    static func urls(of sessionID: UUID) -> [URL] {
        let name = sessionID.uuidString.lowercased()
        let folders = (try? FileManager.default.contentsOfDirectory(at: projects, includingPropertiesForKeys: nil)) ?? []
        return folders
            .flatMap { [$0.appending(path: "\(name).jsonl"), $0.appending(path: name)] }
            .filter { FileManager.default.fileExists(atPath: $0.path) }
    }

    static func transcript(of sessionID: UUID) -> URL? {
        urls(of: sessionID).first { $0.pathExtension == "jsonl" }
    }

    /// Adds a line to the end of a transcript, leaving everything already in it as it was.
    static func append(_ line: Data, to transcript: URL) {
        guard let handle = try? FileHandle(forWritingTo: transcript) else { return }
        defer { try? handle.close() }
        _ = try? handle.seekToEnd()
        try? handle.write(contentsOf: line)
    }

    /// Moves the chat's files to the Trash, so Claude Code no longer lists the chat but it can still be brought back from the Trash.
    static func trash(_ sessionID: UUID) {
        for url in urls(of: sessionID) {
            try? FileManager.default.trashItem(at: url, resultingItemURL: nil)
        }
    }
}
