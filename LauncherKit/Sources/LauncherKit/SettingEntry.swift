/// A setting as the search bar finds it: its title, the tool it belongs to, the subgroup it sits in within that tool, if any, and other words it can be found by.
public struct SettingEntry: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let toolName: String
    public let keywords: [String]
    public let subgroup: String?

    public init(id: String, title: String, toolName: String, keywords: [String] = [], subgroup: String? = nil) {
        self.id = id
        self.title = title
        self.toolName = toolName
        self.keywords = keywords
        self.subgroup = subgroup
    }

    public func match(for query: String) -> NameMatch? {
        ([title, toolName] + keywords)
            .compactMap { NameMatch(name: $0, query: query) }
            .min { $0.rawValue < $1.rawValue }
    }
}
