/// Where settings mode is while nothing is typed: the list of tools, one tool's page, or one subgroup inside a tool. Each page but the first has a parent to go back to.
enum SettingsBarPage: Equatable {
    case tools
    case tool(String)
    case subgroup(tool: String, name: String)

    var id: String {
        switch self {
        case .tools: "page.tools"
        case .tool(let tool): "page.\(tool)"
        case .subgroup(let tool, let name): "page.\(tool).\(name)"
        }
    }

    var title: String {
        switch self {
        case .tools: "Settings"
        case .tool(let tool): tool
        case .subgroup(_, let name): name
        }
    }

    var breadcrumb: String {
        switch self {
        case .tools: "Settings"
        case .tool(let tool): "Settings › \(tool)"
        case .subgroup(let tool, let name): "Settings › \(tool) › \(name)"
        }
    }

    var parent: SettingsBarPage? {
        switch self {
        case .tools: nil
        case .tool: .tools
        case .subgroup(let tool, _): .tool(tool)
        }
    }
}
