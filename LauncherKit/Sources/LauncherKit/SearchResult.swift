public enum SearchResult: Identifiable, Hashable, Sendable {
    case answer(Answer)
    case app(InstalledApp)

    public var id: String {
        switch self {
        case .answer(let answer): "answer:\(answer.output)"
        case .app(let app): "app:\(app.url.path)"
        }
    }
}
