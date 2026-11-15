import Foundation

public enum SettingSearch {
    /// The entries that match a query, grouped by tool and then by subgroup. The tool with the best match comes first, then the subgroup with the best match within it, then the best match within that. An empty query returns every entry in the order given.
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
        clusters(of: entries, by: \.toolName).map { tool in
            SettingGroup(
                toolName: tool.key,
                subgroups: clusters(of: tool.entries, by: \.subgroup).map { SettingSubgroup(name: $0.key, entries: $0.entries) }
            )
        }
    }

    /// Splits entries by a key, keeping each key's entries in their order and the keys in the order they first appear.
    private static func clusters<Key: Hashable>(of entries: [SettingEntry], by key: (SettingEntry) -> Key) -> [(key: Key, entries: [SettingEntry])] {
        var keys: [Key] = []
        var entriesByKey: [Key: [SettingEntry]] = [:]
        for entry in entries {
            let entryKey = key(entry)
            if entriesByKey[entryKey] == nil { keys.append(entryKey) }
            entriesByKey[entryKey, default: []].append(entry)
        }
        return keys.map { ($0, entriesByKey[$0] ?? []) }
    }
}
