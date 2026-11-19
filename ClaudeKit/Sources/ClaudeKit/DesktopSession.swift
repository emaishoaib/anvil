import Foundation

/// A Code session as Claude desktop records it: its own id, the Claude Code session it runs on, its title, or the name of its folder when it has none as Claude desktop shows it, the folder it works in, when it was last active, and whether it was archived. Claude desktop writes one record per session as a JSON file, with the last activity in milliseconds.
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
        let folder = URL(filePath: try container.decode(String.self, forKey: .cwd))
        let savedTitle = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.folder = folder
        title = savedTitle.isEmpty ? folder.lastPathComponent : savedTitle
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

    /// The session Claude desktop runs on the given Claude Code session, archived or not, if it has one.
    public static func session(running sessionID: UUID, in records: [Data]) -> DesktopSession? {
        decoded(records).first { $0.sessionID == sessionID }
    }

    /// The session used last, going by when its Claude Code transcript last changed, so a turn sent from outside Claude desktop counts too. A session whose transcript cannot be found is never the last one.
    public static func lastUsed(of sessions: [DesktopSession], changedAt: (UUID) -> Date?) -> DesktopSession? {
        sessions
            .compactMap { session in changedAt(session.sessionID).map { (session, $0) } }
            .max { $0.1 < $1.1 }?
            .0
    }

    /// The record with a new title, marked as named by the user so Claude desktop does not name it again, keeping everything else in it. A record for any other session, or one that cannot be read, gives nothing back.
    public static func renamed(_ record: Data, running sessionID: UUID, to title: String) -> Data? {
        guard decoded([record]).first?.sessionID == sessionID, var fields = try? JSONSerialization.jsonObject(with: record) as? [String: Any] else { return nil }
        fields["title"] = title
        fields["titleSource"] = "user"
        return try? JSONSerialization.data(withJSONObject: fields, options: .withoutEscapingSlashes)
    }

    private static func decoded(_ records: [Data]) -> [DesktopSession] {
        records.compactMap { try? JSONDecoder().decode(DesktopSession.self, from: $0) }
    }
}
