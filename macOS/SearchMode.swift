import LauncherKit

enum SearchMode: Equatable {
    case launcher
    case defineWord
    case uninstallApp
    case uninstallReview(query: String)
    case wordEntry(Word, query: String)
    case quickLinkForm(QuickLinkFormKind, query: String)
    case settings
    case ruleForm(RuleGroup, isNew: Bool, query: String)
    case keySwapForm(query: String)
    case aiChoice
    case askClaude
    case savedChats

    var placeholder: String {
        switch self {
        case .launcher: Tool.ai.isOn ? "Search for apps and quick links, or press Tab for AI mode…" : "Search for apps and quick links…"
        case .aiChoice: "Start or load a chat…"
        case .defineWord: "Search word…"
        case .uninstallApp: "Search apps to uninstall…"
        case .uninstallReview: "Search files…"
        case .settings: "Search settings…"
        case .askClaude: "Ask Claude…"
        case .savedChats: "Search saved chats…"
        case .wordEntry, .quickLinkForm, .ruleForm, .keySwapForm: ""
        }
    }

    var hasSearchField: Bool {
        switch self {
        case .quickLinkForm, .ruleForm, .keySwapForm: false
        default: true
        }
    }
}
