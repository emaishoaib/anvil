import LauncherKit

enum SearchMode: Equatable {
    case launcher
    case defineWord
    case uninstallApp
    case wordEntry(Word, query: String)
    case quickLinkForm(QuickLinkFormKind, query: String)
    case settings
    case ruleForm(RuleGroup, isNew: Bool, query: String)
    case keySwapForm(query: String)

    var placeholder: String {
        switch self {
        case .launcher: "Search for apps and quick links…"
        case .defineWord: "Search word…"
        case .uninstallApp: "Search apps to uninstall…"
        case .settings: "Search settings…"
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
