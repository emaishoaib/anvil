import Observation
import os

@MainActor @Observable final class MouseSettingsLibrary {
    static let shared = MouseSettingsLibrary()

    private static let file = "mouse.json"
    private static let settingsKey = "mouse.settings"
    private nonisolated static let snapshot = OSAllocatedUnfairLock(initialState: MouseSettings.defaults)

    nonisolated static var current: MouseSettings { snapshot.withLock { $0 } }

    var settings = MouseSettings.defaults {
        didSet {
            let settings = settings
            Self.snapshot.withLock { $0 = settings }
            if settings != lastSaved { persist() }
        }
    }

    private(set) var loadProblem: String?
    @ObservationIgnored private var lastSaved: MouseSettings?

    func start() {
        reload()
    }

    func reload() {
        do {
            loadProblem = nil
            guard let saved = try RuleStorage.load(MouseSettings.self, file: Self.file, settingsKey: Self.settingsKey) else { return persist() }
            lastSaved = saved
            settings = saved
        } catch {
            loadProblem = RuleStorage.problem(reading: Self.file)
        }
    }

    private func persist() {
        guard loadProblem == nil else { return }
        lastSaved = settings
        RuleStorage.save(settings, file: Self.file, settingsKey: Self.settingsKey)
    }
}
