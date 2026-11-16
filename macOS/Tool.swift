import Foundation

nonisolated enum Tool: String, CaseIterable, Identifiable {
    case switcher
    case launcher
    case windows
    case keepAwake
    case rules
    case mouse
    case dockWidgets
    case uninstaller
    case ai

    var id: Self { self }

    var isOnKey: String { "\(rawValue).isOn" }

    var isOnByDefault: Bool { self == .switcher || self == .launcher }

    var canBeTurnedOff: Bool { self != .launcher }

    var isOn: Bool { !canBeTurnedOff || UserDefaults.standard.bool(forKey: isOnKey) }

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: Dictionary(uniqueKeysWithValues: allCases.map { ($0.isOnKey, $0.isOnByDefault) }))
    }

    var name: String {
        switch self {
        case .switcher: "Switcher"
        case .launcher: "Launcher"
        case .windows: "Windows"
        case .keepAwake: "Keep Awake"
        case .rules: "Rules"
        case .mouse: "Mouse"
        case .dockWidgets: "Dock Widgets"
        case .uninstaller: "Uninstaller"
        case .ai: "AI"
        }
    }

    var summary: String {
        switch self {
        case .switcher: "Switch between windows with Option and Tab."
        case .launcher: "Open apps and quick links, and get quick answers, from a search bar."
        case .windows: "Snap windows to halves, thirds and corners of the screen."
        case .keepAwake: "Keep your Mac from going to sleep for a while."
        case .rules: "Remap keys in specific apps and react to system events."
        case .mouse: "Scroll smoothly with a mouse wheel."
        case .dockWidgets: "Show your next meeting in the space beside the Dock."
        case .uninstaller: "Remove apps along with the files they leave in your Library."
        case .ai: "Ask Claude Code about a folder from the search bar."
        }
    }

    var keyResponder: (any KeyResponder)? {
        switch self {
        case .switcher: SwitcherKeys.shared
        case .launcher: LauncherKeys.shared
        case .windows: WindowKeys.shared
        case .rules: RuleKeys.shared
        default: nil
        }
    }

    var shortcuts: [Shortcut] { keyResponder?.shortcuts ?? [] }
}
