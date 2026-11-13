enum RuleActionKind: CaseIterable, Identifiable {
    case sendShortcut
    case chooseMenuItem

    var id: Self { self }

    var title: String {
        switch self {
        case .sendShortcut: "Send Shortcut"
        case .chooseMenuItem: "Choose Menu Item"
        }
    }
}
