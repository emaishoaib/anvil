import AppKit

/// The chats popped out of the search bar into windows of their own, each kept open alongside the bar until its chat is left, which closes its window.
final class ChatWindows {
    static let shared = ChatWindows()

    private var windows: [ChatWindow] = []

    func open(_ chat: ChatModel, at frame: NSRect) {
        let window = ChatWindow(chat: chat, frame: frame)
        chat.onLeave = { [weak self, weak window] _ in
            guard let window else { return }
            window.close()
            self?.windows.removeAll { $0 === window }
        }
        windows.append(window)
        window.show()
    }
}
