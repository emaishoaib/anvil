import ClaudeKit

/// One prompt in a chat, the tools Claude used while answering it, and its answer, which grows as it streams in. A failed turn holds the reason it failed as its answer, and a stopped turn keeps whatever answer came before it was stopped. A turn from earlier in a carried-on chat also holds its answer's markdown already read, since that answer never changes, so a long chat's answers are read once away from the main thread instead of each time they are drawn.
nonisolated struct ChatTurn: Identifiable {
    let id: Int
    let prompt: String
    var tools: [ChatTool] = []
    var answer = ""
    var readAnswer: [AnswerBlock]? = nil
    var isFinished = false
    var failed = false
    var wasStopped = false
}

/// A tool Claude used during a turn, described in a few plain words, and whether it is still running.
nonisolated struct ChatTool: Identifiable {
    enum State {
        case running
        case finished
        case failed
    }

    let id: String
    let summary: String
    var state = State.running
}
