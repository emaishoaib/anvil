public enum LauncherCommand: String, CaseIterable, Sendable {
    case defineWord
    case createQuickLink
    case settings
    case uninstallApp
    case askClaude
    case savedChats

    public var name: String {
        switch self {
        case .defineWord: "Define Word"
        case .createQuickLink: "Create Quick Link"
        case .settings: "Settings"
        case .uninstallApp: "Uninstall App"
        case .askClaude: "AI Ask Claude"
        case .savedChats: "AI Saved Chats Claude"
        }
    }

    public var subtitle: String {
        switch self {
        case .defineWord: "Dictionary"
        case .createQuickLink: "Quick Links"
        case .settings: "Anvil"
        case .uninstallApp: "Uninstaller"
        case .askClaude: "AI"
        case .savedChats: "AI"
        }
    }

    public var keyword: String {
        switch self {
        case .defineWord: "define"
        case .createQuickLink: "link"
        case .settings: "settings"
        case .uninstallApp: "uninstall"
        case .askClaude: "ask"
        case .savedChats: "chats"
        }
    }

    public var launchKey: String { "command:\(rawValue)" }

    public func match(for query: String) -> NameMatch? {
        [NameMatch(name: name, query: query), NameMatch(name: keyword, query: query)]
            .compactMap { $0 }
            .min { $0.rawValue < $1.rawValue }
    }
}
