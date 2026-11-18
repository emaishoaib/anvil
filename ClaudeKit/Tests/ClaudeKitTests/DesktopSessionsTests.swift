import Foundation
import Testing
@testable import ClaudeKit

struct DesktopSessionsTests {
    private static func record(desktopID: String = "local_a02fd0ad", sessionID: String = "564a392c-6b37-4786-9d80-0a5bde99a545", title: String = "Screen not turning on", lastActivityAt: Int = 1_794_979_956_777, isArchived: Bool = false) -> Data {
        Data("""
        {"sessionId":"\(desktopID)","cliSessionId":"\(sessionID)","title":"\(title)","cwd":"/Users/me/docs","lastActivityAt":\(lastActivityAt),"isArchived":\(isArchived),"model":"claude-opus-5-5"}
        """.utf8)
    }

    @Test func aRecordIsReadIntoASession() {
        let sessions = DesktopSessions.newestFirst(from: [Self.record()])
        #expect(sessions == [DesktopSession(
            desktopID: "local_a02fd0ad",
            sessionID: UUID(uuidString: "564a392c-6b37-4786-9d80-0a5bde99a545")!,
            title: "Screen not turning on",
            folder: URL(filePath: "/Users/me/docs"),
            lastActivity: Date(timeIntervalSince1970: 1_794_979_956.777),
            isArchived: false
        )])
    }

    @Test func sessionsAreListedNewestFirst() {
        let older = Self.record(title: "Older", lastActivityAt: 1_000)
        let newer = Self.record(title: "Newer", lastActivityAt: 2_000)
        #expect(DesktopSessions.newestFirst(from: [older, newer]).map(\.title) == ["Newer", "Older"])
    }

    @Test func archivedSessionsAreLeftOut() {
        let sessions = DesktopSessions.newestFirst(from: [Self.record(title: "Kept"), Self.record(title: "Archived", isArchived: true)])
        #expect(sessions.map(\.title) == ["Kept"])
    }

    @Test func aRecordWithoutAClaudeCodeSessionIsLeftOut() {
        let unreadable = Data(#"{"sessionId":"local_b","title":"No session","cwd":"/","lastActivityAt":1}"#.utf8)
        #expect(DesktopSessions.newestFirst(from: [unreadable, Self.record(title: "Readable")]).map(\.title) == ["Readable"])
    }

    @Test func aSessionWithoutATitleHasAnEmptyOne() {
        let untitled = Data(#"{"sessionId":"local_c","cliSessionId":"564a392c-6b37-4786-9d80-0a5bde99a545","cwd":"/","lastActivityAt":1}"#.utf8)
        #expect(DesktopSessions.newestFirst(from: [untitled]).map(\.title) == [""])
    }
}
