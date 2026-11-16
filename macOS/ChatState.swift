/// How far along the chat in AI mode is, which decides what Return and Escape do and what the footer offers. Before the first prompt the folder and mode can still change, and while Claude waits for an approval, Return allows and Escape turns it down.
enum ChatState {
    case notStarted
    case started
    case awaitingApproval
}
