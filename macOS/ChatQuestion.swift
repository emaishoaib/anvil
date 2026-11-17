/// The question shown at the end of a chat before something it can't take back: leaving an unsaved chat, or deleting a saved one. Either way the chat's files move to the Trash.
enum ChatQuestion {
    case leave
    case delete
}
