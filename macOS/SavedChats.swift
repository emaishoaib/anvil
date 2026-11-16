import Foundation

/// A chat kept after it ended, so it can be found and carried on later: its Claude Code session, a title from its first prompt, and the folder it ran in.
struct SavedChat: Codable, Identifiable {
    let id: UUID
    let title: String
    let folder: URL
    let savedAt: Date
}

/// The chats kept after they ended, newest first. Saving a chat that is already kept moves it to the top instead of keeping it twice.
enum SavedChats {
    private static let key = "ai.savedChats"

    static func load() -> [SavedChat] {
        UserDefaults.standard.data(forKey: key).flatMap { try? JSONDecoder().decode([SavedChat].self, from: $0) } ?? []
    }

    static func save(_ chat: ClaudeChatSession) {
        let saved = SavedChat(id: chat.sessionID, title: chat.title, folder: chat.folder, savedAt: .now)
        let chats = [saved] + load().filter { $0.id != saved.id }
        guard let data = try? JSONEncoder().encode(chats) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
