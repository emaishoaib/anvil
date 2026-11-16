import Foundation
import Testing
@testable import ClaudeKit

struct ClaudeArgumentsTests {
    @Test func theChatArgumentsNameTheSessionAndMode() throws {
        let sessionID = try #require(UUID(uuidString: "97B846CF-11CC-4FD7-89A9-B9BDB06776C6"))
        let arguments = ClaudeArguments.chat(sessionID: sessionID, mode: .acceptEdits)
        #expect(value(after: "--session-id", in: arguments) == "97b846cf-11cc-4fd7-89a9-b9bdb06776c6")
        #expect(value(after: "--permission-mode", in: arguments) == "acceptEdits")
    }

    @Test func approvalsAreAskedOfTheAppDrivingTheChat() {
        let arguments = ClaudeArguments.chat(sessionID: UUID(), mode: .manual)
        #expect(value(after: "--permission-prompts", in: arguments) == "host")
    }

    @Test func theChatTalksInStreamJSONWithoutItsInteractiveScreen() {
        let arguments = ClaudeArguments.chat(sessionID: UUID(), mode: .manual)
        #expect(arguments.contains("--print"))
        #expect(arguments.contains("--include-partial-messages"))
        #expect(value(after: "--input-format", in: arguments) == "stream-json")
        #expect(value(after: "--output-format", in: arguments) == "stream-json")
    }

    private func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else { return nil }
        return arguments[index + 1]
    }
}
