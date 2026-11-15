import LauncherKit

enum SearchMode: Equatable {
    case launcher
    case defineWord
    case wordEntry(Word, query: String)
    case quickLinkForm(QuickLinkFormKind, query: String)
    case settings

    var placeholder: String {
        switch self {
        case .launcher: "Search for apps and quick links…"
        case .defineWord: "Search word…"
        case .settings: "Search settings…"
        case .wordEntry, .quickLinkForm: ""
        }
    }

    var hasSearchField: Bool {
        if case .quickLinkForm = self { false } else { true }
    }
}
