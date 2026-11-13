import AppKit
import Observation
import RulesKit

@Observable final class KeySwapLibrary {
    static let shared = KeySwapLibrary()

    private static let file = "key-swaps.json"
    private static let settingsKey = "rules.keySwaps"
    private static let builtInKeyboard = #"{"Built-In":true,"PrimaryUsagePage":1,"PrimaryUsage":6}"#

    private(set) var swaps: [KeySwap] = []
    private(set) var loadProblem: String?

    private init() {
        reload()
    }

    func start() {
        if !swaps.isEmpty { apply() }
        _ = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
            MainActor.assumeIsolated {
                if !KeySwapLibrary.shared.swaps.isEmpty { KeySwapLibrary.shared.apply() }
            }
        }
    }

    func add(_ swap: KeySwap) {
        swaps.append(swap)
        persist()
    }

    func delete(_ swap: KeySwap) {
        swaps.removeAll { $0.id == swap.id }
        persist()
    }

    func reload() {
        let before = swaps
        do {
            loadProblem = nil
            guard let saved = try SettingsStorage.load([KeySwap].self, file: Self.file, settingsKey: Self.settingsKey) else { return persist() }
            swaps = saved
            if swaps != before { apply() }
        } catch {
            loadProblem = SettingsStorage.problem(reading: Self.file)
        }
    }

    func apply() {
        guard Tool.rules.isOn else { return }
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/hidutil")
        process.arguments = ["property", "--matching", Self.builtInKeyboard, "--set", KeySwap.userKeyMapping(for: swaps)]
        try? process.run()
    }

    private func persist() {
        guard loadProblem == nil else { return }
        SettingsStorage.save(swaps, file: Self.file, settingsKey: Self.settingsKey)
        apply()
    }
}
