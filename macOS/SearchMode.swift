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
    case aliasForm(query: String)
    case shellTextForm(ShellText, query: String)
    case phraseForm(SpokenPhrase, query: String)
    case askClaude
    case desktopSessions

    var placeholder: String {
        switch self {
        case .launcher: Tool.ai.isOn ? "Search for apps and quick links, or press Tab for AI mode…" : "Search for apps and quick links…"
        case .defineWord: "Search word…"
        case .uninstallApp: "Search apps to uninstall…"
        case .uninstallReview: "Search files…"
        case .settings: "Search settings…"
        case .askClaude: "Ask Claude…"
        case .desktopSessions: "Search chats, or press Tab for a new chat…"
        case .wordEntry, .quickLinkForm, .ruleForm, .keySwapForm, .aliasForm, .shellTextForm, .phraseForm: ""
        }
    }

    var hasSearchField: Bool {
        switch self {
        case .quickLinkForm, .ruleForm, .keySwapForm, .aliasForm, .shellTextForm, .phraseForm: false
        default: true
        }
    }
}
