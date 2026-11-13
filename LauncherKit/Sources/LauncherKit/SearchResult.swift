public enum SearchResult: Identifiable, Hashable, Sendable {
    case answer(Answer)
    case app(InstalledApp)
    case command(LauncherCommand)
    case quickLink(QuickLink)
    case word(Word)

    public var id: String {
        switch self {
        case .answer(let answer): "answer:\(answer.output)"
        case .app(let app): "app:\(app.url.path)"
        case .command(let command): command.launchKey
        case .quickLink(let link): link.launchKey
        case .word(let word): "word:\(word.text)"
        }
    }

    public var launchKey: String? {
        switch self {
        case .app(let app): app.url.path
        case .command(let command): command.launchKey
        case .quickLink(let link): link.launchKey
        case .answer, .word: nil
        }
    }

    var name: String {
        switch self {
        case .answer(let answer): answer.output
        case .app(let app): app.name
        case .command(let command): command.name
        case .quickLink(let link): link.name
        case .word(let word): word.text
        }
    }

    func match(for query: String) -> NameMatch? {
        switch self {
        case .app(let app): app.match(for: query)
        case .command(let command): command.match(for: query)
        case .quickLink(let link): link.match(for: query)
        case .answer, .word: nil
        }
    }
}
