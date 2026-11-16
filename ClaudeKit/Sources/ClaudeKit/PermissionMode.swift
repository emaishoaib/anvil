/// How freely Claude Code may act in a chat, from asking before every change to never asking. Each raw value is the name Claude Code's permission mode flag takes, and the modes are listed in the order Claude desktop lists them.
public enum PermissionMode: String, CaseIterable, Sendable {
    case auto
    case manual
    case acceptEdits
    case plan
    case bypassPermissions

    public var title: String {
        switch self {
        case .auto: "Auto"
        case .manual: "Manual"
        case .acceptEdits: "Accept Edits"
        case .plan: "Plan"
        case .bypassPermissions: "Bypass Permissions"
        }
    }

    public var summary: String {
        switch self {
        case .auto: "Claude decides which actions need your approval"
        case .manual: "Ask before every change"
        case .acceptEdits: "Edit files without asking, and ask before anything else"
        case .plan: "Make a plan, and ask before carrying it out"
        case .bypassPermissions: "Never ask"
        }
    }

    /// The mode after this one, going back to the first after the last, for stepping through them with one key.
    public var next: PermissionMode {
        let modes = Self.allCases
        let index = modes.firstIndex(of: self) ?? modes.startIndex
        return modes[(index + 1) % modes.count]
    }
}
