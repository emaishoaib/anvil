import AppKit
import Observation

/// The saved chats page: the chats that still exist, narrowed by the search field to those whose title or folder contains it, and the one selected. Trashing a chat takes it off the page and keeps the selection in the same place.
@Observable final class SavedChatList {
    private(set) var chats = SavedChats.existing()
    private(set) var selected = 0

    func chats(matching query: String) -> [SavedChat] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return chats }
        return chats.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.folder.path.localizedCaseInsensitiveContains(query) }
    }

    func selectedChat(matching query: String) -> SavedChat? {
        let matching = chats(matching: query)
        return matching.indices.contains(selected) ? matching[selected] : nil
    }

    func select(_ index: Int) {
        selected = index
    }

    func moveSelection(by offset: Int, matching query: String) {
        let count = chats(matching: query).count
        guard count > 0 else { return }
        selected = min(max(selected + offset, 0), count - 1)
    }

    func trashSelected(matching query: String) {
        guard let chat = selectedChat(matching: query) else { return NSSound.beep() }
        SavedChats.trash(chat)
        chats.removeAll { $0.id == chat.id }
        selected = min(selected, max(chats(matching: query).count - 1, 0))
    }
}
