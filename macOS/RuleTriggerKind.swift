enum RuleTriggerKind: CaseIterable, Identifiable {
    case shortcut
    case mouseButton

    var id: Self { self }

    var title: String {
        switch self {
        case .shortcut: "Shortcut"
        case .mouseButton: "Mouse Button"
        }
    }
}
