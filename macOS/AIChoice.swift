import Foundation

/// The two ways on from AI mode's first page: start a new chat with Claude Code, or load a saved chat to carry on with it. The search field narrows them to those whose title contains it.
enum AIChoice: CaseIterable {
    case startChat
    case loadChat

    var title: String {
        switch self {
        case .startChat: "Start Chat"
        case .loadChat: "Load Chat"
        }
    }

    var subtitle: String {
        switch self {
        case .startChat: "Ask Claude Code something new"
        case .loadChat: "Carry on with a Claude desktop session"
        }
    }

    var symbol: String {
        switch self {
        case .startChat: "sparkles"
        case .loadChat: "tray.full.fill"
        }
    }

    static func matching(_ query: String) -> [AIChoice] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return allCases }
        return allCases.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
}
