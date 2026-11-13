public enum LauncherCommand: String, CaseIterable, Sendable {
    case defineWord

    public var name: String {
        switch self {
        case .defineWord: "Define Word"
        }
    }

    public var subtitle: String {
        switch self {
        case .defineWord: "Dictionary"
        }
    }

    public var keyword: String {
        switch self {
        case .defineWord: "define"
        }
    }

    public var launchKey: String { "command:\(rawValue)" }

    public func match(for query: String) -> NameMatch? {
        [NameMatch(name: name, query: query), NameMatch(name: keyword, query: query)]
            .compactMap { $0 }
            .min { $0.rawValue < $1.rawValue }
    }
}
