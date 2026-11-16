import Foundation
import Testing
@testable import ClaudeKit

struct ClaudePromptTests {
    @Test func aPromptBecomesOneLineHoldingAUserMessage() throws {
        let line = ClaudePrompt.line("What does SearchModel do?")
        let text = try #require(String(data: line, encoding: .utf8))
        #expect(text.hasSuffix("\n"))
        #expect(text.dropLast().contains("\n") == false)
        let json = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        let message = try #require(json["message"] as? [String: String])
        #expect(json["type"] as? String == "user")
        #expect(message == ["role": "user", "content": "What does SearchModel do?"])
    }

    @Test func newlinesAndQuotesInAPromptStayOnOneLine() throws {
        let line = ClaudePrompt.line("first line\nsecond \"quoted\" line")
        let text = try #require(String(data: line, encoding: .utf8))
        #expect(text.dropLast().contains("\n") == false)
        let json = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        let message = try #require(json["message"] as? [String: String])
        #expect(message["content"] == "first line\nsecond \"quoted\" line")
    }
}
