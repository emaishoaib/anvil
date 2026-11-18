/// How far along the chat in AI mode is, which decides what Return and Escape do and what the footer offers. Before the first prompt the folder and mode can still change. While Claude Code is signed out, Return signs it in and then sends the prompt in the field, and Escape stops a sign-in still waiting on the browser. While Claude answers, Escape stops it. After that, Escape leaves a chat saved into Claude desktop straight away, and otherwise asks whether to leave without saving, where Command S saves the chat and leaves, and Escape goes back to chatting. While Claude waits for an approval, Escape turns it down. On each of these questions, left and right move the highlight between its buttons and Return presses the highlighted one, which starts as Leave or Allow. When Claude Code turns out too old to chat, Return updates it and then sends the prompt again, Escape leaves the chat as usual, and while it updates, Escape stops the update.
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
}
