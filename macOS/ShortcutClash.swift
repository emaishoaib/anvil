import Foundation

enum ShortcutClash {
    case tool(Tool)
    case macOS

    var name: String {
        switch self {
        case .tool(let tool): tool.name
        case .macOS: "macOS"
        }
    }

    static func warning(for clashes: [ShortcutClash]) -> String? {
        clashes.isEmpty ? nil : "Also used by \(clashes.map(\.name).formatted(.list(type: .and)))"
    }
}

extension Tool {
    func clashes(with shortcut: Shortcut) -> [ShortcutClash] {
        clashes(with: shortcut, systemShortcuts: SystemShortcuts.enabled())
    }

    func clashes(with shortcut: Shortcut, systemShortcuts: Set<KeyCombo>) -> [ShortcutClash] {
        let tools = Tool.allCases.filter { $0 != self && $0.shortcuts.contains { $0.combo == shortcut.combo } }
        return tools.map(ShortcutClash.tool) + (systemShortcuts.contains(shortcut.combo) ? [.macOS] : [])
    }
}
