import Foundation

public enum SettingSearch {
    /// The entries that match a query, grouped by tool. The tool with the best match comes first, and so does the best match within a tool. An empty query returns every entry in the order given.
    public static func matches(for query: String, in entries: [SettingEntry]) -> [SettingGroup] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return groups(of: entries) }
        let ranked = entries.enumerated()
            .compactMap { index, entry in entry.match(for: query).map { (entry: entry, match: $0, index: index) } }
            .sorted { ($0.match.rawValue, $0.index) < ($1.match.rawValue, $1.index) }
            .map(\.entry)
        return groups(of: ranked)
    }

    private static func groups(of entries: [SettingEntry]) -> [SettingGroup] {
        var toolNames: [String] = []
        var entriesByTool: [String: [SettingEntry]] = [:]
        for entry in entries {
            if entriesByTool[entry.toolName] == nil { toolNames.append(entry.toolName) }
            entriesByTool[entry.toolName, default: []].append(entry)
        }
        return toolNames.map { SettingGroup(toolName: $0, entries: entriesByTool[$0] ?? []) }
    }
}
