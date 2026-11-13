import AppKit
import Observation
import RulesKit

@Observable final class KeySwapLibrary {
    static let shared = KeySwapLibrary()

    private static let key = "rules.keySwaps"
    private static let builtInKeyboard = #"{"Built-In":true,"PrimaryUsagePage":1,"PrimaryUsage":6}"#

    private(set) var swaps: [KeySwap]

    private init() {
        swaps = UserDefaults.standard.data(forKey: Self.key).flatMap { try? JSONDecoder().decode([KeySwap].self, from: $0) } ?? []
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

    func apply() {
        guard Tool.rules.isOn else { return }
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/hidutil")
        process.arguments = ["property", "--matching", Self.builtInKeyboard, "--set", KeySwap.userKeyMapping(for: swaps)]
        try? process.run()
    }

    private func persist() {
        UserDefaults.standard.set(try? JSONEncoder().encode(swaps), forKey: Self.key)
        apply()
    }
}
