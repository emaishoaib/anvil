import Foundation

/// Claude Code asking whether a tool may run, waiting for a yes or no. The question names what would happen, and a command or a plan comes with its full text, so it can be read before answering.
public struct Approval: Equatable, Sendable {
    public enum Detail: Equatable, Sendable {
        case command(String)
        case plan(String)
    }

    public let requestID: String
    public let tool: ToolCall

    public init(requestID: String, tool: ToolCall) {
        self.requestID = requestID
        self.tool = tool
    }

    public var question: String {
        switch tool.name {
        case "Bash": "Run this command?"
        case "Edit", "MultiEdit", "NotebookEdit": "Edit \(fileName ?? "this file")?"
        case "Write": "Write \(fileName ?? "this file")?"
        case "ExitPlanMode": "Carry out this plan?"
        case "WebFetch": tool.input["url"].flatMap { URL(string: $0)?.host() }.map { "Read \($0)?" } ?? "Read this web page?"
        default: "Allow \(tool.name)?"
        }
    }

    public var detail: Detail? {
        switch tool.name {
        case "Bash": tool.input["command"].map(Detail.command)
        case "ExitPlanMode": tool.input["plan"].map(Detail.plan)
        default: nil
        }
    }

    private var fileName: String? {
        (tool.input["file_path"] ?? tool.input["notebook_path"]).map { URL(filePath: $0).lastPathComponent }
    }
}
