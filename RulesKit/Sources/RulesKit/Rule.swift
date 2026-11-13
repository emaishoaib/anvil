import Foundation

public struct Rule: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var trigger: RuleTrigger
    public var apps: RuleApps
    public var action: RuleAction

    public init(id: UUID = UUID(), trigger: RuleTrigger, apps: RuleApps = .all, action: RuleAction) {
        self.id = id
        self.trigger = trigger
        self.apps = apps
        self.action = action
    }
}
