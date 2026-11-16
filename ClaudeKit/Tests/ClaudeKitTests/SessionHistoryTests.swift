import Testing
@testable import ClaudeKit

struct SessionHistoryTests {
    @Test func eachPromptStartsATurnWithItsAnswer() {
        let transcript = lines(
            #"{"type":"queue-operation","operation":"enqueue"}"#,
            #"{"type":"user","message":{"role":"user","content":"hi"}}"#,
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Hi! What are we working on?"}]}}"#,
            #"{"type":"user","message":{"role":"user","content":"again"}}"#,
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Still here."}]}}"#
        )
        #expect(SessionHistory.turns(in: transcript) == [
            PastTurn(prompt: "hi", answer: "Hi! What are we working on?"),
            PastTurn(prompt: "again", answer: "Still here."),
        ])
    }

    @Test func toolsAreKeptWithTheTurnAndTextBeforeAToolStaysApart() {
        let transcript = lines(
            #"{"type":"user","origin":{"kind":"human"},"message":{"role":"user","content":"What is the answer?"}}"#,
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"thinking","thinking":""}]}}"#,
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Let me look."}]}}"#,
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"toolu_1","name":"Read","input":{"file_path":"/tmp/notes.md"}}]}}"#,
            #"{"type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_1","type":"tool_result","content":"42"}]}}"#,
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"**42**"}]}}"#
        )
        let tool = ToolCall(id: "toolu_1", name: "Read", input: ["file_path": "/tmp/notes.md"])
        #expect(SessionHistory.turns(in: transcript) == [PastTurn(prompt: "What is the answer?", answer: "Let me look.\n\n**42**", tools: [tool])])
    }

    @Test func aToolThatFailedIsRemembered() {
        let transcript = lines(
            #"{"type":"user","message":{"role":"user","content":"push it"}}"#,
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"toolu_1","name":"Bash","input":{"command":"git push"}}]}}"#,
            #"{"type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_1","type":"tool_result","content":"denied","is_error":true}]}}"#
        )
        #expect(SessionHistory.turns(in: transcript).first?.failedToolIDs == ["toolu_1"])
    }

    @Test func linesClaudeCodeAddsItselfDoNotStartTurns() {
        let transcript = lines(
            #"{"type":"user","message":{"role":"user","content":"real prompt"}}"#,
            #"{"type":"user","isMeta":true,"message":{"role":"user","content":[{"type":"text","text":"[Image: source: /tmp/1.png]"}]}}"#,
            #"{"type":"user","origin":{"kind":"task-notification"},"message":{"role":"user","content":"A task finished"}}"#,
            #"{"type":"user","message":{"role":"user","content":"<command-name>/clear</command-name>"}}"#,
            #"{"type":"user","message":{"role":"user","content":"[Request interrupted by user]"}}"#,
            #"{"type":"user","isCompactSummary":true,"message":{"role":"user","content":"This session is being continued"}}"#
        )
        #expect(SessionHistory.turns(in: transcript).map(\.prompt) == ["real prompt"])
    }

    @Test func aPromptWithAnImageKeepsItsText() {
        let transcript = lines(#"{"type":"user","origin":{"kind":"human"},"message":{"role":"user","content":[{"type":"text","text":"look at this"},{"type":"image","source":{}}]}}"#)
        #expect(SessionHistory.turns(in: transcript).map(\.prompt) == ["look at this"])
    }

    @Test func whatAnAgentDidIsLeftOut() {
        let transcript = lines(
            #"{"type":"user","message":{"role":"user","content":"find it"}}"#,
            #"{"type":"user","isSidechain":true,"message":{"role":"user","content":"Search the code"}}"#,
            #"{"type":"assistant","isSidechain":true,"message":{"role":"assistant","content":[{"type":"text","text":"agent notes"}]}}"#,
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Found it."}]}}"#
        )
        #expect(SessionHistory.turns(in: transcript) == [PastTurn(prompt: "find it", answer: "Found it.")])
    }

    @Test func brokenLinesAndAnswersBeforeAnyPromptAreSkipped() {
        let transcript = lines(
            "not json",
            #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"orphan"}]}}"#,
            #"{"type":"user","message":{"role":"user","content":"hello"}}"#
        )
        #expect(SessionHistory.turns(in: transcript) == [PastTurn(prompt: "hello")])
    }

    private func lines(_ lines: String...) -> String {
        lines.joined(separator: "\n")
    }
}
