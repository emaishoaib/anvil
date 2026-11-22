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
    case phraseForm(SpokenPhrase, query: String)
    case currencyPicker(fromSettings: Bool, query: String)
    case askClaude
    case desktopSessions
    case screenshot

    var placeholder: String {
        switch self {
        case .launcher: Tool.ai.isOn ? "Search for apps and quick links, or press Tab for AI mode…" : "Search for apps and quick links…"
        case .defineWord: "Search word…"
        case .uninstallApp: "Search apps to uninstall…"
        case .uninstallReview: "Search files…"
        case .settings: "Search settings…"
        case .askClaude: "Ask Claude…"
        case .desktopSessions: "Search chats, or press Tab for a new chat…"
        case .screenshot: "Choose what to do with the screenshot…"
        case .currencyPicker: "Search currencies to add…"
        case .wordEntry, .quickLinkForm, .ruleForm, .keySwapForm, .phraseForm: ""
        }
    }

    var hasSearchField: Bool {
        switch self {
        case .quickLinkForm, .ruleForm, .keySwapForm, .phraseForm: false
        default: true
        }
    }
}
