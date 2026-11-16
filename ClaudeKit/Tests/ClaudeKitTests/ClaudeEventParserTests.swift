import Testing
@testable import ClaudeKit

struct ClaudeEventParserTests {
    @Test func theFirstLineGivesTheSessionIDModelAndFolder() {
        let line = #"{"type":"system","subtype":"init","cwd":"/Users/me/project","session_id":"97b846cf","tools":["Read","Bash"],"model":"claude-haiku-4-5","permissionMode":"default","apiKeySource":"none"}"#
        #expect(ClaudeEventParser.events(in: line) == [.started(sessionID: "97b846cf", model: "claude-haiku-4-5", folder: "/Users/me/project")])
    }

    @Test func aStatusLineGivesNothing() {
        let line = #"{"type":"system","subtype":"status","status":"requesting","session_id":"97b846cf"}"#
        #expect(ClaudeEventParser.events(in: line).isEmpty)
    }

    @Test func aTextDeltaGivesItsText() {
        let line = #"{"type":"stream_event","event":{"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"The answer is "}},"session_id":"97b846cf"}"#
        #expect(ClaudeEventParser.events(in: line) == [.text("The answer is ")])
    }

    @Test func streamedPiecesThatAreNotTextGiveNothing() {
        let lines = [
            #"{"type":"stream_event","event":{"type":"message_start","message":{"id":"msg_1"}}}"#,
            #"{"type":"stream_event","event":{"type":"content_block_start","index":1,"content_block":{"type":"tool_use","id":"toolu_1","name":"Read","input":{}}}}"#,
            #"{"type":"stream_event","event":{"type":"content_block_delta","index":1,"delta":{"type":"input_json_delta","partial_json":"{\"file_"}}}"#,
            #"{"type":"stream_event","event":{"type":"message_stop"}}"#,
        ]
        #expect(lines.flatMap(ClaudeEventParser.events).isEmpty)
    }

    @Test func aToolUseGivesTheToolAndItsTextInputs() {
        let line = #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"toolu_1","name":"Read","input":{"file_path":"/Users/me/project/notes.md","limit":20}}]}}"#
        #expect(ClaudeEventParser.events(in: line) == [.toolStarted(ToolCall(id: "toolu_1", name: "Read", input: ["file_path": "/Users/me/project/notes.md"]))])
    }

    @Test func severalToolUsesInOneMessageGiveOneEventEach() {
        let line = #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Let me look."},{"type":"tool_use","id":"toolu_1","name":"Glob","input":{"pattern":"*.swift"}},{"type":"tool_use","id":"toolu_2","name":"Bash","input":{"command":"git log"}}]}}"#
        #expect(ClaudeEventParser.events(in: line) == [
            .toolStarted(ToolCall(id: "toolu_1", name: "Glob", input: ["pattern": "*.swift"])),
            .toolStarted(ToolCall(id: "toolu_2", name: "Bash", input: ["command": "git log"])),
        ])
    }

    @Test func aWholeMessageOfTextGivesNothingBecauseItsTextAlreadyStreamedIn() {
        let line = #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"The answer is 42."}]}}"#
        #expect(ClaudeEventParser.events(in: line).isEmpty)
    }

    @Test func aToolResultFinishesTheToolAndSaysWhetherItFailed() {
        let line = #"{"type":"user","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"toolu_1","content":"42"},{"type":"tool_result","tool_use_id":"toolu_2","content":"denied","is_error":true}]}}"#
        #expect(ClaudeEventParser.events(in: line) == [
            .toolFinished(id: "toolu_1", failed: false),
            .toolFinished(id: "toolu_2", failed: true),
        ])
    }

    @Test func aUserMessageOfPlainTextGivesNothing() {
        let line = #"{"type":"user","message":{"role":"user","content":"Read notes.md"}}"#
        #expect(ClaudeEventParser.events(in: line).isEmpty)
    }

    @Test func theResultGivesTheAnswer() {
        let line = #"{"type":"result","subtype":"success","is_error":false,"result":"The answer is **42**.","session_id":"97b846cf","num_turns":2}"#
        #expect(ClaudeEventParser.events(in: line) == [.finished(answer: "The answer is **42**.", failed: false)])
    }

    @Test func aResultMarkedAsAnErrorFailsEvenWhenItsSubtypeSaysSuccess() {
        let line = #"{"type":"result","subtype":"success","is_error":true,"terminal_reason":"api_error","result":"Failed to authenticate: OAuth session expired and could not be refreshed","session_id":"97b846cf"}"#
        #expect(ClaudeEventParser.events(in: line) == [.finished(answer: "Failed to authenticate: OAuth session expired and could not be refreshed", failed: true)])
    }

    @Test func aResultThatRanOutOfTurnsFailsWithNoAnswer() {
        let line = #"{"type":"result","subtype":"error_max_turns","is_error":true,"session_id":"97b846cf"}"#
        #expect(ClaudeEventParser.events(in: line) == [.finished(answer: "", failed: true)])
    }

    @Test func aLineThatIsNotJSONGivesNothing() {
        #expect(ClaudeEventParser.events(in: "Warning: something went wrong").isEmpty)
        #expect(ClaudeEventParser.events(in: "").isEmpty)
    }
}
