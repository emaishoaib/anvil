import Foundation
import Testing
@testable import ClaudeKit

struct TranscriptTitleTests {
    private static let sessionID = UUID(uuidString: "564A392C-6B37-4786-9D80-0A5BDE99A545")!

    @Test func aNameBecomesOneCustomTitleLine() throws {
        let line = TranscriptTitle.line("Anvil chat fixes", sessionID: Self.sessionID)
        let text = try #require(String(data: line, encoding: .utf8))
        #expect(text.hasSuffix("\n"))
        #expect(text.dropLast().contains("\n") == false)
        let json = try #require(try JSONSerialization.jsonObject(with: line) as? [String: String])
        #expect(json == ["type": "custom-title", "customTitle": "Anvil chat fixes", "sessionId": "564a392c-6b37-4786-9d80-0a5bde99a545"])
    }

    @Test func slashesAndQuotesInANameStayOnOneLine() throws {
        let line = TranscriptTitle.line("UI/UX \"fixes\"\nround two", sessionID: Self.sessionID)
        let text = try #require(String(data: line, encoding: .utf8))
        #expect(text.dropLast().contains("\n") == false)
        let json = try #require(try JSONSerialization.jsonObject(with: line) as? [String: String])
        #expect(json["customTitle"] == "UI/UX \"fixes\"\nround two")
    }
}
