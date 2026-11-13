import Carbon.HIToolbox

nonisolated enum SwitchAction {
    case open(SwitchScope, number: Int)
    case next
    case move(SwitchDirection)
    case cancel
    case release
}

nonisolated enum SwitchScope: CaseIterable {
    case allApps, activeApp

    init?(keyCode: Int) {
        guard let scope = Self.allCases.first(where: { $0.shortcut.combo.keyCode == keyCode }) else { return nil }
        self = scope
    }

    init?(combo: KeyCombo) {
        guard let scope = Self.allCases.first(where: { $0.shortcut.combo == combo }) else { return nil }
        self = scope
    }

    var shortcut: Shortcut {
        switch self {
        case .allApps: Shortcut(combo: KeyCombo(keyCode: kVK_Tab, modifiers: .option), action: "Switch between windows on this Space")
        case .activeApp: Shortcut(combo: KeyCombo(keyCode: kVK_ANSI_Grave, modifiers: .option), action: "Switch between the active app's windows")
        }
    }
}

nonisolated enum SwitchDirection {
    case left, right, up, down

    init?(keyCode: Int) {
        switch keyCode {
        case kVK_LeftArrow: self = .left
        case kVK_RightArrow: self = .right
        case kVK_UpArrow: self = .up
        case kVK_DownArrow: self = .down
        default: return nil
        }
    }
}
