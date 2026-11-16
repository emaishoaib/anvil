/// A tool Claude Code started using, such as reading a file or running a command, with the inputs it gave the tool that are plain text. Inputs that are numbers, lists or objects are left out.
public struct ToolCall: Equatable, Sendable {
    public let id: String
    public let name: String
    public let input: [String: String]

    public init(id: String, name: String, input: [String: String] = [:]) {
        self.id = id
        self.name = name
        self.input = input
    }
}
