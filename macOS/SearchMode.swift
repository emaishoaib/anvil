import LauncherKit

enum SearchMode: Equatable {
    case launcher
    case defineWord
    case wordEntry(Word, query: String)
    case quickLinkForm(QuickLinkFormKind, query: String)
    case settings
    case ruleForm(RuleGroup, isNew: Bool, query: String)

    var placeholder: String {
        switch self {
        case .launcher: "Search for apps and quick links…"
        case .defineWord: "Search word…"
        case .settings: "Search settings…"
        case .wordEntry, .quickLinkForm, .ruleForm: ""
        }
    }

    var hasSearchField: Bool {
        switch self {
        case .quickLinkForm, .ruleForm: false
        default: true
        }
    }
}
