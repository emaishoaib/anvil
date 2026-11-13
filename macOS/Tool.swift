import Foundation

nonisolated enum Tool: String, CaseIterable, Identifiable {
    case switcher
    case launcher
    case windows
    case keepAwake
    case rules
    case dockWidgets

    var id: Self { self }

    var isOnKey: String { "\(rawValue).isOn" }

    var isOnByDefault: Bool { self == .switcher }

    var isOn: Bool { UserDefaults.standard.bool(forKey: isOnKey) }

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
        case .dockWidgets: "Dock Widgets"
        }
    }

    var symbol: String {
        switch self {
        case .switcher: "rectangle.on.rectangle"
        case .launcher: "magnifyingglass"
        case .windows: "rectangle.split.2x1"
        case .keepAwake: "cup.and.saucer"
        case .rules: "keyboard"
        case .dockWidgets: "dock.rectangle"
        }
    }

    var summary: String {
        switch self {
        case .switcher: "Switch between windows with Option and Tab."
        case .launcher: "Open apps and quick links, and get quick answers, from a search bar."
        case .windows: "Snap windows to halves, thirds and corners of the screen."
        case .keepAwake: "Keep your Mac from going to sleep for a while."
        case .rules: "Remap keys in specific apps and react to system events."
        case .dockWidgets: "Show your next meeting in the space beside the Dock."
        }
    }

    var shortcuts: [Shortcut] {
        switch self {
        case .switcher: [
            Shortcut(keys: "⌥ Tab", action: "Switch between windows on this Space"),
            Shortcut(keys: "⌥ `", action: "Switch between the active app's windows"),
        ]
        default: []
        }
    }
}
