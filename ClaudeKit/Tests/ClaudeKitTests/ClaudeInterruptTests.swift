import Foundation
import Testing
@testable import ClaudeKit

struct ClaudeInterruptTests {
    @Test func anInterruptIsOneControlRequestLine() throws {
        let line = ClaudeInterrupt.line(requestID: "stop_1")
        #expect(String(data: line, encoding: .utf8)?.hasSuffix("\n") == true)
        let json = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        #expect(json["type"] as? String == "control_request")
        #expect(json["request_id"] as? String == "stop_1")
        #expect(json["request"] as? [String: String] == ["subtype": "interrupt"])
    }

    @Test func eachInterruptGetsItsOwnRequestID() throws {
        let first = try #require(try JSONSerialization.jsonObject(with: ClaudeInterrupt.line()) as? [String: Any])
        let second = try #require(try JSONSerialization.jsonObject(with: ClaudeInterrupt.line()) as? [String: Any])
        #expect(first["request_id"] as? String != second["request_id"] as? String)
    }
}
