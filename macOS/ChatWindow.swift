import AppKit
import SwiftUI

/// A chat shown in a window of its own, apart from the search bar, so the bar stays free for everything else. It opens where it is told to, takes the keyboard straight away, and answers the same keys a chat answers in the bar.
final class ChatWindow {
    let chat: ChatModel
    private let panel: ChatPanel

    init(chat: ChatModel, frame: NSRect) {
        self.chat = chat
        panel = ChatPanel(frame: frame)
        let content = NSHostingView(rootView: ChatWindowView(chat: chat))
        if let background = panel.contentView {
            content.frame = background.bounds
            content.autoresizingMask = [.width, .height]
            background.addSubview(content)
        }
        panel.handleKey = { [weak self] event in self?.handleKey(event) ?? false }
    }

    /// Shows the window, or brings it forward when it is already showing, and gives it the keyboard.
    func show() {
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel.orderOut(nil)
    }

    private func handleKey(_ event: NSEvent) -> Bool {
        let editor = panel.firstResponder as? NSTextView
        let chooseFolder = { [chat] in
            NSApp.activate()
            chat.setup.chooseFolder()
        }
        return ChatKeys.handle(Int(event.keyCode), modifiers: event.modifierFlags, in: chat, editor: editor, chooseFolder: chooseFolder) == .handled
    }
}
