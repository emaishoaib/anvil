/// What happens to a chat when it is left, decided ahead of time so leaving it does not ask: keep it in the saved chats, or move it to the Trash.
enum ChatEnding {
    case save
    case discard
}
