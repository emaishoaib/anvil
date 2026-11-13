import LauncherKit

enum SearchMode: Equatable {
    case launcher
    case defineWord
    case wordEntry(Word, query: String)
    case quickLinkForm(query: String)

    var placeholder: String {
        switch self {
        case .launcher: "Search for apps and quick links…"
        case .defineWord: "Search word…"
        case .wordEntry, .quickLinkForm: ""
        }
    }

    var hasSearchField: Bool {
        if case .quickLinkForm = self { false } else { true }
    }
}
