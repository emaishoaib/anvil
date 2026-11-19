import Foundation

/// Where a prompt said by voice is shown once it is sent: in the search bar or in a chat window of its own, on the chat it went to, or in Claude desktop on that session. The choice is saved in the user defaults, where the chat window keeps the name it had when it was a pinned search bar, so the choice carries over.
enum AfterSending: String, CaseIterable {
    case bar, chatWindow = "pinnedBar", claudeDesktop

    private static let savedKey = "ai.afterSending"
    private static let defaultChoice = AfterSending.bar

    static var current: AfterSending {
        get { UserDefaults.standard.string(forKey: savedKey).flatMap(AfterSending.init(rawValue:)) ?? defaultChoice }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: savedKey) }
    }

    var name: String {
        switch self {
        case .bar: "The search bar"
        case .chatWindow: "A chat window"
        case .claudeDesktop: "Claude desktop"
        }
    }
}
