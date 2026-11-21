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

    @Test func aPromptWithAnImageSendsTheImageBeforeItsText() throws {
        let png = Data([0x89, 0x50, 0x4E, 0x47])
        let line = ClaudePrompt.line("What is this?", pngImages: [png])
        let text = try #require(String(data: line, encoding: .utf8))
        #expect(text.dropLast().contains("\n") == false)
        let blocks = try content(of: line)
        #expect(blocks.count == 2)
        let source = try #require(blocks[0]["source"] as? [String: String])
        #expect(blocks[0]["type"] as? String == "image")
        #expect(source == ["type": "base64", "media_type": "image/png", "data": png.base64EncodedString()])
        #expect(blocks[1]["type"] as? String == "text")
        #expect(blocks[1]["text"] as? String == "What is this?")
    }

    @Test func anImageSentWithoutTextHasNoTextBlock() throws {
        let blocks = try content(of: ClaudePrompt.line("", pngImages: [Data([1, 2, 3])]))
        #expect(blocks.map { $0["type"] as? String } == ["image"])
    }

    private func content(of line: Data) throws -> [[String: Any]] {
        let json = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        let message = try #require(json["message"] as? [String: Any])
        return try #require(message["content"] as? [[String: Any]])
    }
}
