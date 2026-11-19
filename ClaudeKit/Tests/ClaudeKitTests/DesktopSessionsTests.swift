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

    @Test func aSessionClaudeDesktopHasIsFound() {
        #expect(DesktopSessions.session(running: UUID(uuidString: "564a392c-6b37-4786-9d80-0a5bde99a545")!, in: [Self.record()])?.desktopID == "local_a02fd0ad")
    }

    @Test func anArchivedSessionIsStillFound() {
        #expect(DesktopSessions.session(running: UUID(uuidString: "564a392c-6b37-4786-9d80-0a5bde99a545")!, in: [Self.record(isArchived: true)]) != nil)
    }

    @Test func aSessionClaudeDesktopDoesNotHaveIsNotFound() {
        #expect(DesktopSessions.session(running: UUID(), in: [Self.record()]) == nil)
    }

    @Test func theLastSessionIsTheOneWhoseTranscriptChangedLast() {
        let older = DesktopSessions.newestFirst(from: [Self.record(desktopID: "local_older", sessionID: "11111111-1111-1111-1111-111111111111", lastActivityAt: 2_000)])
        let newer = DesktopSessions.newestFirst(from: [Self.record(desktopID: "local_newer", sessionID: "22222222-2222-2222-2222-222222222222", lastActivityAt: 1_000)])
        let changes = [older[0].sessionID: Date(timeIntervalSince1970: 1), newer[0].sessionID: Date(timeIntervalSince1970: 2)]
        #expect(DesktopSessions.lastUsed(of: older + newer, changedAt: { changes[$0] })?.desktopID == "local_newer")
    }

    @Test func aSessionWithoutATranscriptIsNeverTheLastOne() {
        let sessions = DesktopSessions.newestFirst(from: [Self.record()])
        #expect(DesktopSessions.lastUsed(of: sessions, changedAt: { _ in nil }) == nil)
    }

    @Test func aSessionWithoutATitleIsNamedAfterItsFolder() {
        let untitled = Data(#"{"sessionId":"local_c","cliSessionId":"564a392c-6b37-4786-9d80-0a5bde99a545","cwd":"/Users/me/anvil","lastActivityAt":1}"#.utf8)
        #expect(DesktopSessions.newestFirst(from: [untitled]).map(\.title) == ["anvil"])
    }

    @Test func aRenamedRecordHasTheNewTitleSetByTheUser() throws {
        let renamed = try #require(DesktopSessions.renamed(Self.record(), running: UUID(uuidString: "564a392c-6b37-4786-9d80-0a5bde99a545")!, to: "UI/UX fixes"))
        let fields = try #require(try JSONSerialization.jsonObject(with: renamed) as? [String: Any])
        #expect(fields["title"] as? String == "UI/UX fixes")
        #expect(fields["titleSource"] as? String == "user")
        #expect(fields["model"] as? String == "claude-opus-5-5")
        #expect(fields["isArchived"] as? Bool == false)
        #expect(DesktopSessions.newestFirst(from: [renamed]).map(\.title) == ["UI/UX fixes"])
    }

    @Test func aRecordForAnotherSessionIsNotRenamed() {
        #expect(DesktopSessions.renamed(Self.record(), running: UUID(), to: "Other") == nil)
    }

    @Test func aSessionWithAnEmptyTitleIsNamedAfterItsFolder() {
        #expect(DesktopSessions.newestFirst(from: [Self.record(title: "")]).map(\.title) == ["docs"])
    }
}
