import Carbon.HIToolbox
import LauncherKit

extension QuickLinkAction {
    var shortcut: KeyCombo? {
        switch self {
        case .open: KeyCombo(keyCode: kVK_Return, modifiers: [])
        case .openWith: KeyCombo(keyCode: kVK_ANSI_O, modifiers: [.shift, .command])
        case .edit: KeyCombo(keyCode: kVK_ANSI_E, modifiers: .command)
        case .duplicate: KeyCombo(keyCode: kVK_ANSI_D, modifiers: .command)
        case .resetRanking: nil
        case .copyName: KeyCombo(keyCode: kVK_ANSI_C, modifiers: [.shift, .command])
        case .copyLink: KeyCombo(keyCode: kVK_ANSI_Period, modifiers: [.shift, .command])
        case .delete: KeyCombo(keyCode: kVK_ANSI_X, modifiers: .control)
        }
    }

    static func forShortcut(_ combo: KeyCombo) -> QuickLinkAction? {
        guard !combo.modifiers.isEmpty else { return nil }
        return allCases.first { $0.shortcut == combo }
    }
}
