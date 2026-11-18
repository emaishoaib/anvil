import Foundation

/// A Code session as Claude desktop records it: its own id, the Claude Code session it runs on, its title, the folder it works in, when it was last active, and whether it was archived. Claude desktop writes one record per session as a JSON file, with the last activity in milliseconds.
public struct DesktopSession: Decodable, Equatable, Sendable {
    public let desktopID: String
    public let sessionID: UUID
    public let title: String
    public let folder: URL
    public let lastActivity: Date
    public let isArchived: Bool

    public init(desktopID: String, sessionID: UUID, title: String, folder: URL, lastActivity: Date, isArchived: Bool) {
        self.desktopID = desktopID
        self.sessionID = sessionID
        self.title = title
        self.folder = folder
        self.lastActivity = lastActivity
        self.isArchived = isArchived
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, cliSessionId, title, cwd, lastActivityAt, isArchived
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        desktopID = try container.decode(String.self, forKey: .sessionId)
        sessionID = try container.decode(UUID.self, forKey: .cliSessionId)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        folder = URL(filePath: try container.decode(String.self, forKey: .cwd))
        lastActivity = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .lastActivityAt) / 1000)
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    }
}

/// Claude desktop's Code sessions, read from their records. Any record that cannot be read is left out, such as one written by a later version of Claude desktop in a different shape.
public enum DesktopSessions {
    /// The sessions to list, newest first, leaving out archived ones.
    public static func newestFirst(from records: [Data]) -> [DesktopSession] {
        decoded(records)
            .filter { !$0.isArchived }
            .sorted { $0.lastActivity > $1.lastActivity }
    }

    /// Whether Claude desktop already has a session running on the given Claude Code session, archived or not.
    public static func contains(_ sessionID: UUID, in records: [Data]) -> Bool {
        decoded(records).contains { $0.sessionID == sessionID }
    }

    private static func decoded(_ records: [Data]) -> [DesktopSession] {
        records.compactMap { try? JSONDecoder().decode(DesktopSession.self, from: $0) }
    }
}
