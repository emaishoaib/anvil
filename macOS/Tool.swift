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

    static func named(_ name: String) -> Tool? {
        allCases.first { $0.name == name }
    }

    /// Whether there is anything behind the tool yet. Dock Widgets has its switch but nothing that uses it, so its settings page is greyed out.
    var isBuilt: Bool { self != .dockWidgets }

    var icon: ToolIcon {
        switch self {
        case .switcher: .hop
        case .launcher: .symbol("magnifyingglass")
        case .windows: .symbol("rectangle.split.2x1")
        case .keepAwake: .symbol("cup.and.saucer")
        case .rules: .symbol("arrow.triangle.branch")
        case .mouse: .symbol("computermouse")
        case .dockWidgets: .symbol("dock.rectangle")
        case .uninstaller: .symbol("trash")
        case .ai: .symbol("point.3.connected.trianglepath.dotted")
        }
    }

    /// Where the tool comes on the settings page, after General. It is kept apart from the order of the cases, which decides which tool answers a key first.
    var settingsPosition: Int {
        switch self {
        case .launcher: 0
        case .switcher: 1
        case .windows: 2
        case .rules: 3
        case .mouse: 4
        case .keepAwake: 5
        case .ai: 6
        case .dockWidgets: 7
        case .uninstaller: 8
        }
    }

    var keyResponder: (any KeyResponder)? {
        switch self {
        case .switcher: SwitcherKeys.shared
        case .launcher: LauncherKeys.shared
        case .windows: WindowKeys.shared
        case .rules: RuleKeys.shared
        case .ai: AIKeys.shared
        default: nil
        }
    }

    var shortcuts: [Shortcut] { keyResponder?.shortcuts ?? [] }
}
