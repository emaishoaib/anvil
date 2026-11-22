import Observation
import os

@MainActor @Observable final class MouseSettingsLibrary {
    static let shared = MouseSettingsLibrary()

    private static let section = "mouse"
    private static let oldFile = "mouse.json"
    private static let settingsKey = "mouse.settings"
    private nonisolated static let snapshot = OSAllocatedUnfairLock(initialState: MouseSettings.defaults)

    nonisolated static var current: MouseSettings { snapshot.withLock { $0 } }

    var settings = MouseSettings.defaults {
        didSet {
            let settings = settings
            Self.snapshot.withLock { $0 = settings }
            if settings != lastSaved { persist() }
            if settings.ratchetDisengageSpeed != oldValue.ratchetDisengageSpeed || settings.dpi != oldValue.dpi {
                LogitechDevices.shared.applyMouseTool()
            }
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
            guard let saved = try SettingsStorage.load(MouseSettings.self, section: Self.section, oldFile: Self.oldFile, settingsKey: Self.settingsKey) else { return persist() }
            lastSaved = saved
            settings = saved
        } catch {
            loadProblem = SettingsStorage.problem(reading: Self.section)
        }
    }

    private func persist() {
        guard loadProblem == nil else { return }
        lastSaved = settings
        SettingsStorage.save(settings, section: Self.section, settingsKey: Self.settingsKey)
    }
}
