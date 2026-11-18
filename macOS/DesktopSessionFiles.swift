import ClaudeKit
import Foundation

/// The records Claude desktop keeps for its Code sessions, one JSON file per session named after its desktop id, in a folder per account and organisation under `~/Library/Application Support/Claude/claude-code-sessions`. Every one of those folders is looked in, since Anvil does not know which account Claude desktop is signed in to.
nonisolated enum DesktopSessionFiles {
    private static let sessions = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/Application Support/Claude/claude-code-sessions")
    private static let recordPrefix = "local_"

    static func newestFirst() -> [DesktopSession] {
        DesktopSessions.newestFirst(from: records())
    }

    static func contains(_ sessionID: UUID) -> Bool {
        DesktopSessions.contains(sessionID, in: records())
    }

    private static func records() -> [Data] {
        recordFiles().compactMap { try? Data(contentsOf: $0) }
    }

    private static func recordFiles() -> [URL] {
        contents(of: sessions)
            .flatMap(contents)
            .flatMap(contents)
            .filter { $0.lastPathComponent.hasPrefix(recordPrefix) && $0.pathExtension == "json" }
    }

    private static func contents(of folder: URL) -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
    }
}
