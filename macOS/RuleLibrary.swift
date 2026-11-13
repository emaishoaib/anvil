import Foundation
import Observation
import RulesKit

@Observable final class RuleLibrary {
    static let shared = RuleLibrary()

    private static let file = "rules.json"
    private static let settingsKey = "rules.rules"

    private(set) var rules = Rules()
    private(set) var loadProblem: String?

    private init() {
        reload()
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

    func reload() {
        do {
            loadProblem = nil
            guard let saved = try SettingsStorage.load([Rule].self, file: Self.file, settingsKey: Self.settingsKey) else { return persist() }
            rules = Rules(saved)
            RuleKeys.shared.use(rules)
        } catch {
            loadProblem = SettingsStorage.problem(reading: Self.file)
        }
    }

    private func persist() {
        RuleKeys.shared.use(rules)
        guard loadProblem == nil else { return }
        SettingsStorage.save(rules.rules, file: Self.file, settingsKey: Self.settingsKey)
    }
}
