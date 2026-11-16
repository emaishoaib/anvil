/// How far along the chat in AI mode is, which decides what Return and Escape do and what the footer offers. Before the first prompt the folder and mode can still change. While Claude Code is signed out, Return signs it in, and Escape stops a sign-in still waiting on the browser. While Claude waits for an approval, Return allows and Escape turns it down.
enum ChatState {
    case signedOut
    case signingIn
    case notStarted
    case started
    case awaitingApproval
}
