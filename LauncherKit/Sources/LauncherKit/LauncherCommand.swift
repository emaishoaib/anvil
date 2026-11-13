public enum LauncherCommand: String, CaseIterable, Sendable {
    case defineWord
    case createQuickLink

    public var name: String {
        switch self {
        case .defineWord: "Define Word"
        case .createQuickLink: "Create Quick Link"
        }
    }

    public var subtitle: String {
        switch self {
        case .defineWord: "Dictionary"
        case .createQuickLink: "Quick Links"
        }
    }

    public var keyword: String {
        switch self {
        case .defineWord: "define"
        case .createQuickLink: "link"
        }
    }

    public var launchKey: String { "command:\(rawValue)" }

    public func match(for query: String) -> NameMatch? {
        [NameMatch(name: name, query: query), NameMatch(name: keyword, query: query)]
            .compactMap { $0 }
            .min { $0.rawValue < $1.rawValue }
    }
}
