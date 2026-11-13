public struct Rules: Equatable, Sendable {
    public private(set) var rules: [Rule]

    public init(_ rules: [Rule] = []) {
        self.rules = rules
    }

    public func rule(for trigger: RuleTrigger, in bundleID: String?) -> Rule? {
        let matching = rules.filter { $0.trigger == trigger && $0.apps.apply(to: bundleID) }
        return matching.first(where: \.apps.isChosen) ?? matching.first
    }

    public func hasDragRules(forButton number: Int, in bundleID: String?) -> Bool {
        rules.contains { rule in
            guard case .mouseDrag(number, _) = rule.trigger else { return false }
            return rule.apps.apply(to: bundleID)
        }
    }

    public mutating func save(_ rule: Rule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
        } else {
            rules.append(rule)
        }
    }

    public mutating func delete(_ rule: Rule) {
        rules.removeAll { $0.id == rule.id }
    }
}
