import Carbon.HIToolbox
import WindowKit

nonisolated enum WindowCommand: Hashable, Sendable {
    case action(WindowAction)
    case restore

    static let allCases: [WindowCommand] = WindowAction.allCases.map(WindowCommand.action) + [.restore]

    var title: String {
        switch self {
        case .action(let action): action.title
        case .restore: "Restore"
        }
    }

    var defaultCombo: KeyCombo? {
        switch self {
        case .action(let action): action.defaultCombo
        case .restore: KeyCombo(keyCode: kVK_Delete, modifiers: [.control, .option])
        }
    }

    var savedKey: String {
        switch self {
        case .action(let action): "windows.shortcut.\(action.rawValue)"
        case .restore: "windows.shortcut.restore"
        }
    }

    @MainActor func perform() {
        switch self {
        case .action(let action): Snapping.shared.snapFocusedWindow(to: action)
        case .restore: Snapping.shared.restoreFocusedWindow()
        }
    }
}
