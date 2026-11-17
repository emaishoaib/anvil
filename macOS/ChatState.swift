/// How far along the chat in AI mode is, which decides what Return and Escape do and what the footer offers. Before the first prompt the folder and mode can still change. While Claude Code is signed out, Return signs it in, and Escape stops a sign-in still waiting on the browser. While Claude answers, Escape stops it. After that, Escape leaves a saved chat straight away, and otherwise asks whether to leave without saving, where Return leaves, Command S saves the chat and leaves, and Escape goes back to chatting. While Claude waits for an approval, Return allows and Escape turns it down.
enum ChatState {
    case signedOut
    case signingIn
    case notStarted
    case started
    case answering
    case awaitingApproval
    case askingToLeave
}
