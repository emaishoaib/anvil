import AppKit

/// The chats popped out of the search bar into windows of their own, each kept open alongside the bar.
final class ChatWindows {
    static let shared = ChatWindows()

    private var windows: [ChatWindow] = []

    func open(_ chat: ChatModel, at frame: NSRect) {
        let window = ChatWindow(chat: chat, frame: frame)
        windows.append(window)
        window.show()
    }
}
