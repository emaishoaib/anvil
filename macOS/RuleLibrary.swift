import Foundation
import Observation
import RulesKit

@Observable final class RuleLibrary {
    static let shared = RuleLibrary()

    private static let key = "rules.rules"

    private(set) var rules: Rules

    private init() {
        let saved = UserDefaults.standard.data(forKey: Self.key).flatMap { try? JSONDecoder().decode([Rule].self, from: $0) }
        rules = Rules(saved ?? [])
    }

    var all: [Rule] { rules.rules }

    func contains(_ id: UUID) -> Bool {
        all.contains { $0.id == id }
    }

    func save(_ rule: Rule) {
        rules.save(rule)
        persist()
    }

    func delete(_ rule: Rule) {
        rules.delete(rule)
        persist()
    }

    private func persist() {
        RuleKeys.shared.use(rules)
        UserDefaults.standard.set(try? JSONEncoder().encode(rules.rules), forKey: Self.key)
    }
}
