import Foundation

extension ToolCall {
    /// What the tool is doing, in a few plain words, such as "Reading notes.md" or "Running git log". A file is named without its folders, a command by the description Claude gave it when there is one, and a tool Anvil does not know by its own name.
    public var summary: String {
        switch name {
        case "Read": "Reading \(fileName ?? "a file")"
        case "Edit", "MultiEdit": "Editing \(fileName ?? "a file")"
        case "Write": "Writing \(fileName ?? "a file")"
        case "NotebookEdit": "Editing \(fileName(in: "notebook_path") ?? "a notebook")"
        case "Bash": input["description"] ?? input["command"].map { "Running \($0)" } ?? "Running a command"
        case "Glob": input["pattern"].map { "Finding files matching \($0)" } ?? "Finding files"
        case "Grep": input["pattern"].map { "Searching for \($0)" } ?? "Searching files"
        case "WebFetch": input["url"].flatMap { URL(string: $0)?.host() }.map { "Reading \($0)" } ?? "Reading a web page"
        case "WebSearch": input["query"].map { "Searching the web for \($0)" } ?? "Searching the web"
        case "Task", "Agent": input["description"].map { "Asking an agent to \($0.lowercasedFirstLetter)" } ?? "Asking an agent"
        case "TodoWrite": "Updating the task list"
        default: "Using \(name)"
        }
    }

    private var fileName: String? {
        fileName(in: "file_path")
    }

    private func fileName(in field: String) -> String? {
        input[field].map { URL(filePath: $0).lastPathComponent }
    }
}

private extension String {
    var lowercasedFirstLetter: String {
        prefix(1).lowercased() + dropFirst()
    }
}
