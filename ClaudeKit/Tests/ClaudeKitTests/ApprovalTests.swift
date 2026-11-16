import Foundation
import Testing
@testable import ClaudeKit

struct ApprovalTests {
    @Test func aToolPermissionRequestAsksForApproval() {
        let line = #"{"type":"control_request","request_id":"req_1","request":{"subtype":"can_use_tool","tool_name":"Bash","input":{"command":"git push","timeout":60000},"tool_use_id":"toolu_1","permission_suggestions":[]}}"#
        let tool = ToolCall(id: "toolu_1", name: "Bash", input: ["command": "git push"])
        #expect(ClaudeEventParser.events(in: line) == [.approvalRequested(Approval(requestID: "req_1", tool: tool))])
    }

    @Test func otherControlRequestsAreNotApprovals() {
        let line = #"{"type":"control_request","request_id":"req_2","request":{"subtype":"hook_callback","callback_id":"hook_1"}}"#
        #expect(ClaudeEventParser.events(in: line).isEmpty)
    }

    @Test func aCancelledRequestWithdrawsItsApproval() {
        let line = #"{"type":"control_cancel_request","request_id":"req_1"}"#
        #expect(ClaudeEventParser.events(in: line) == [.approvalWithdrawn(requestID: "req_1")])
    }

    @Test func theQuestionNamesWhatWouldHappen() {
        #expect(approval("Bash", ["command": "git push"]).question == "Run this command?")
        #expect(approval("Edit", ["file_path": "/Users/me/anvil/README.md"]).question == "Edit README.md?")
        #expect(approval("Write", ["file_path": "/Users/me/new.swift"]).question == "Write new.swift?")
        #expect(approval("ExitPlanMode", ["plan": "1. Do it"]).question == "Carry out this plan?")
        #expect(approval("WebFetch", ["url": "https://swift.org/blog"]).question == "Read swift.org?")
        #expect(approval("mcp__github__create_issue", [:]).question == "Allow mcp__github__create_issue?")
    }

    @Test func aCommandOrAPlanComesWithItsFullText() {
        #expect(approval("Bash", ["command": "rm -rf build"]).detail == .command("rm -rf build"))
        #expect(approval("ExitPlanMode", ["plan": "## Plan\n1. Do it"]).detail == .plan("## Plan\n1. Do it"))
        #expect(approval("Edit", ["file_path": "/a.swift"]).detail == nil)
    }

    @Test func allowingAnswersTheRequestByItsID() throws {
        let response = try answer(ApprovalAnswer.line(for: approval("Bash", [:]), allowed: true))
        #expect(response.requestID == "req_1")
        #expect(response.decision == ["behavior": "allow"])
    }

    @Test func turningDownTellsClaudeWhy() throws {
        let response = try answer(ApprovalAnswer.line(for: approval("Bash", [:]), allowed: false))
        #expect(response.decision["behavior"] == "deny")
        #expect(response.decision["message"]?.isEmpty == false)
    }

    private func approval(_ name: String, _ input: [String: String]) -> Approval {
        Approval(requestID: "req_1", tool: ToolCall(id: "toolu_1", name: name, input: input))
    }

    private func answer(_ line: Data) throws -> (requestID: String?, decision: [String: String]) {
        #expect(String(data: line, encoding: .utf8)?.hasSuffix("\n") == true)
        let json = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        #expect(json["type"] as? String == "control_response")
        let response = try #require(json["response"] as? [String: Any])
        #expect(response["subtype"] as? String == "success")
        let decision = try #require(response["response"] as? [String: String])
        return (response["request_id"] as? String, decision)
    }
}
