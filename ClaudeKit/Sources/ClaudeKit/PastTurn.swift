/// A turn from earlier in a saved chat: the prompt, the answer Claude gave, and the tools it used along the way, with the ones that failed.
public struct PastTurn: Equatable, Sendable {
    public let prompt: String
    public var answer = ""
    public var tools: [ToolCall] = []
    public var failedToolIDs: Set<String> = []

    public init(prompt: String, answer: String = "", tools: [ToolCall] = [], failedToolIDs: Set<String> = []) {
        self.prompt = prompt
        self.answer = answer
        self.tools = tools
        self.failedToolIDs = failedToolIDs
    }
}
