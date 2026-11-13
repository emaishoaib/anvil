enum ShortcutClash {
    case tool(Tool)
    case macOS

    var name: String {
        switch self {
        case .tool(let tool): tool.name
        case .macOS: "macOS"
        }
    }
}

extension Tool {
    func clashes(with shortcut: Shortcut) -> [ShortcutClash] {
        let tools = Tool.allCases.filter { $0 != self && $0.shortcuts.contains { $0.combo == shortcut.combo } }
        let usedByMacOS = SystemShortcuts.enabled().contains(shortcut.combo)
        return tools.map(ShortcutClash.tool) + (usedByMacOS ? [.macOS] : [])
    }
}
