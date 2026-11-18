import Foundation

/// Where a prompt said by voice is shown once it is sent: in the search bar, pinned or not, on the chat it went to, or in Claude desktop on that session. The choice is saved in the user defaults.
enum AfterSending: String, CaseIterable {
    case bar, pinnedBar, claudeDesktop

    private static let savedKey = "ai.afterSending"
    private static let defaultChoice = AfterSending.bar

    static var current: AfterSending {
        get { UserDefaults.standard.string(forKey: savedKey).flatMap(AfterSending.init(rawValue:)) ?? defaultChoice }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: savedKey) }
    }

    var name: String {
        switch self {
        case .bar: "The search bar"
        case .pinnedBar: "The search bar, pinned"
        case .claudeDesktop: "Claude desktop"
        }
    }
}
