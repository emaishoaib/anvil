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
    case askClaude

    var placeholder: String {
        switch self {
        case .launcher: "Search for apps and quick links…"
        case .defineWord: "Search word…"
        case .uninstallApp: "Search apps to uninstall…"
        case .uninstallReview: "Search files…"
        case .settings: "Search settings…"
        case .askClaude: "Ask Claude…"
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
