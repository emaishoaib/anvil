/// One prompt in a chat, the tools Claude used while answering it, and its answer, which grows as it streams in. A failed turn holds the reason it failed as its answer.
struct ChatTurn: Identifiable {
    let id: Int
    let prompt: String
    var tools: [ChatTool] = []
    var answer = ""
    var isFinished = false
    var failed = false
}

/// A tool Claude used during a turn, described in a few plain words, and whether it is still running.
struct ChatTool: Identifiable {
    enum State {
        case running
        case finished
        case failed
    }

    let id: String
    let summary: String
    var state = State.running
}
