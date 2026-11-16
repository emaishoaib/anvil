/// One prompt in a chat and Claude's answer to it, which grows as the answer streams in. A failed turn holds the reason it failed as its answer.
struct ChatTurn: Identifiable {
    let id: Int
    let prompt: String
    var answer = ""
    var isFinished = false
    var failed = false
}
