/// How far along the chat in AI mode is, which decides what Return and Escape do and what the footer offers. Before the first prompt the folder and mode can still change. While Claude Code is signed out, Return signs it in and then sends the prompt in the field, and Escape stops a sign-in still waiting on the browser. While Claude answers, Escape stops it. After that, Escape leaves a saved chat straight away, and otherwise asks whether to leave without saving, where Return leaves, Command S saves the chat and leaves, and Escape goes back to chatting. Command D on a saved chat asks whether to delete it, where Return deletes and Escape goes back to chatting. While Claude waits for an approval, Return allows and Escape turns it down. When Claude Code turns out too old to chat, Return updates it and then sends the prompt again, Escape leaves the chat as usual, and while it updates, Escape stops the update.
enum ChatState {
    case signedOut
    case signingIn
    case notStarted
    case started
    case answering
    case outdated
    case updating
    case awaitingApproval
    case askingToLeave
    case askingToDelete
}
