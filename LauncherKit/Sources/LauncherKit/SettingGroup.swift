/// The settings of one tool, listed under that tool's header and split into its subgroups.
public struct SettingGroup: Hashable, Sendable {
    public let toolName: String
    public let subgroups: [SettingSubgroup]

    public var entries: [SettingEntry] { subgroups.flatMap(\.entries) }
}

/// Settings that sit together under a subheader inside a tool. Settings outside any subgroup have no name.
public struct SettingSubgroup: Hashable, Sendable {
    public let name: String?
    public let entries: [SettingEntry]
}
