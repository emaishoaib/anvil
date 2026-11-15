/// The settings of one tool, listed under that tool's header.
public struct SettingGroup: Hashable, Sendable {
    public let toolName: String
    public let entries: [SettingEntry]
}
