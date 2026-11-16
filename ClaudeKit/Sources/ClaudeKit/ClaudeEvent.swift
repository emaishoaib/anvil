/// One thing Claude Code reports while it answers a prompt, read from a line of its stream JSON output. An answer that failed, such as when Claude Code is not signed in, still finishes, with the reason as its answer. An approval Claude Code asked for can be withdrawn before it is answered, such as when the answer is stopped.
public enum ClaudeEvent: Equatable, Sendable {
    case started(sessionID: String, model: String, folder: String)
    case text(String)
    case toolStarted(ToolCall)
    case toolFinished(id: String, failed: Bool)
    case finished(answer: String, failed: Bool)
    case approvalRequested(Approval)
    case approvalWithdrawn(requestID: String)
}
