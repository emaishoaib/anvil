enum RuleActionKind: CaseIterable, Identifiable {
    case sendShortcut
    case chooseMenuItem
    case playSound
    case quitApp
    case resizeWindow
    case swipe

    var id: Self { self }

    var title: String {
        switch self {
        case .sendShortcut: "Send Shortcut"
        case .chooseMenuItem: "Choose Menu Item"
        case .playSound: "Play Sound"
        case .quitApp: "Quit the App"
        case .resizeWindow: "Resize Its Window"
        case .swipe: "Swipe Back or Forward"
        }
    }

    func isAvailable(for trigger: RuleTriggerKind) -> Bool {
        (self != .quitApp && self != .resizeWindow) || trigger.isAppEvent
    }
}
