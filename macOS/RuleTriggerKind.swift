enum RuleTriggerKind: CaseIterable, Identifiable {
    case shortcut
    case mouseButton
    case mouseDrag
    case appOpens
    case appComesToFront

    var id: Self { self }

    var title: String {
        switch self {
        case .shortcut: "Shortcut"
        case .mouseButton: "Mouse Button"
        case .mouseDrag: "Mouse Button Drag"
        case .appOpens: "App Opens"
        case .appComesToFront: "App Comes to Front"
        }
    }

    var isAppEvent: Bool {
        switch self {
        case .shortcut, .mouseButton, .mouseDrag: false
        case .appOpens, .appComesToFront: true
        }
    }
}
