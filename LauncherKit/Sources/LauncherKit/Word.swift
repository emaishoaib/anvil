public struct Word: Hashable, Sendable {
    public let text: String
    public let definition: String

    public init(text: String, definition: String) {
        self.text = text
        self.definition = definition
    }
}
