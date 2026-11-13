import Foundation
import os

nonisolated final class WindowShortcuts: Sendable {
    static let shared = WindowShortcuts()

    private static let clearedText = "none"

    private let combos = OSAllocatedUnfairLock(initialState: WindowShortcuts.loaded())

    var all: [WindowCommand: KeyCombo] { combos.withLock { $0 } }

    func command(for combo: KeyCombo) -> WindowCommand? {
        combos.withLock { combos in combos.first { $0.value == combo }?.key }
    }

    func set(_ combo: KeyCombo?, for command: WindowCommand) {
        let previousOwners = combos.withLock { combos in
            let owners = combos.filter { $0.key != command && $0.value == combo }.map(\.key)
            for owner in owners { combos[owner] = nil }
            combos[command] = combo
            return owners
        }
        for owner in previousOwners { Self.save(nil, for: owner) }
        Self.save(combo, for: command)
    }

    private static func save(_ combo: KeyCombo?, for command: WindowCommand) {
        UserDefaults.standard.set(combo?.savedText ?? clearedText, forKey: command.savedKey)
    }

    private static func loaded() -> [WindowCommand: KeyCombo] {
        Dictionary(uniqueKeysWithValues: WindowCommand.allCases.compactMap { command in
            let saved = UserDefaults.standard.string(forKey: command.savedKey)
            let combo = saved == nil ? command.defaultCombo : saved.flatMap(KeyCombo.init(savedText:))
            return combo.map { (command, $0) }
        })
    }
}
