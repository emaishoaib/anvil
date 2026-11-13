enum RuleActionKind: CaseIterable, Identifiable {
    case sendShortcut
    case chooseMenuItem
    case playSound
    case quitApp

    var id: Self { self }

    var title: String {
        switch self {
        case .sendShortcut: "Send Shortcut"
        case .chooseMenuItem: "Choose Menu Item"
        case .playSound: "Play Sound"
        case .quitApp: "Quit the App"
        }
    }

    func isAvailable(for trigger: RuleTriggerKind) -> Bool {
        self != .quitApp || trigger.isAppEvent
    }
}
