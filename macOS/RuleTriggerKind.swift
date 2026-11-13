enum RuleTriggerKind: CaseIterable, Identifiable {
    case shortcut
    case mouseButton
    case appOpens

    var id: Self { self }

    var title: String {
        switch self {
        case .shortcut: "Shortcut"
        case .mouseButton: "Mouse Button"
        case .appOpens: "App Opens"
        }
    }

    var isAppEvent: Bool {
        switch self {
        case .shortcut, .mouseButton: false
        case .appOpens: true
        }
    }
}
