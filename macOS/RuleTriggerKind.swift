enum RuleTriggerKind: CaseIterable, Identifiable {
    case shortcut
    case mouseButton
    case appOpens
    case appComesToFront

    var id: Self { self }

    var title: String {
        switch self {
        case .shortcut: "Shortcut"
        case .mouseButton: "Mouse Button"
        case .appOpens: "App Opens"
        case .appComesToFront: "App Comes to Front"
        }
    }

    var isAppEvent: Bool {
        switch self {
        case .shortcut, .mouseButton: false
        case .appOpens, .appComesToFront: true
        }
    }
}
