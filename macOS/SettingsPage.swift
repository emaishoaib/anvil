enum SettingsPage: Hashable {
    case general
    case tool(Tool)

    static let all: [SettingsPage] = [.general] + Tool.allCases.map(SettingsPage.tool)

    var title: String {
        switch self {
        case .general: "General"
        case .tool(let tool): tool.name
        }
    }
}
