import ClaudeKit

/// The turns of a chat in order, changed as Claude Code reports on the newest one. Only the newest turn can still be answering, so every change lands on it. The chat's title is its first prompt's first line.
struct ChatTranscript {
    private static let titleLength = 80

    private(set) var turns: [ChatTurn] = []

    var isAnswering: Bool {
        turns.last.map { !$0.isFinished } ?? false
    }

    var title: String {
        let firstLine = turns.first?.prompt.split(separator: "\n").first.map(String.init) ?? ""
        return String(firstLine.prefix(Self.titleLength))
    }

    mutating func start(_ prompt: String) {
        turns.append(ChatTurn(id: turns.count, prompt: prompt))
    }

    mutating func addText(_ text: String) {
        updateLast { $0.answer += text }
    }

    mutating func startTool(_ call: ToolCall) {
        updateLast { turn in
            turn.tools.append(ChatTool(id: call.id, summary: call.summary))
            if !turn.answer.isEmpty, !turn.answer.hasSuffix("\n") { turn.answer += "\n\n" }
        }
    }

    mutating func finishTool(_ id: String, failed: Bool) {
        updateLast { turn in
            guard let index = turn.tools.firstIndex(where: { $0.id == id }) else { return }
            turn.tools[index].state = failed ? .failed : .finished
        }
    }

    mutating func finish(answer: String, failed: Bool) {
        updateLast { turn in
            if turn.answer.isEmpty || failed, !answer.isEmpty { turn.answer = answer }
            turn.isFinished = true
            turn.failed = failed
        }
    }

    mutating func markStopped() {
        updateLast { turn in
            turn.isFinished = true
            turn.wasStopped = true
        }
    }

    private mutating func updateLast(_ change: (inout ChatTurn) -> Void) {
        guard !turns.isEmpty else { return }
        change(&turns[turns.count - 1])
    }
}
