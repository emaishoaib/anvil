enum SearchMode {
    case launcher
    case defineWord

    var placeholder: String {
        switch self {
        case .launcher: "Search for apps and quick links…"
        case .defineWord: "Search word…"
        }
    }
}
