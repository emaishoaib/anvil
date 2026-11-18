import SwiftUI

/// A button on a question card at the end of a chat: leaving an unsaved chat, deleting a saved one, or answering an approval. Left and right move the highlight between a card's buttons, and Return presses the highlighted one.
enum CardChoice {
    case keepChatting
    case saveAndLeave
    case leave
    case deny
    case allow

    static let leaving: [CardChoice] = [.keepChatting, .saveAndLeave, .leave]
    static let approving: [CardChoice] = [.deny, .allow]

    var title: String {
        switch self {
        case .keepChatting: "Keep Chatting"
        case .saveAndLeave: "Save and Leave"
        case .leave: "Leave"
        case .deny: "Deny"
        case .allow: "Allow"
        }
    }

    var role: ButtonRole? {
        switch self {
        case .leave: .destructive
        case .keepChatting, .saveAndLeave, .deny, .allow: nil
        }
    }
}
