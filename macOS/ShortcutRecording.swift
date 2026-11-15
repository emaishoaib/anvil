import AppKit

/// Listens for the next key typed into the search bar while a shortcut row records, with Anvil's own shortcuts paused so the keys reach it. A local monitor sees each key before the search panel does, so the bar's own handling of Escape, Return and the arrows stays out of the way.
@MainActor @Observable final class ShortcutRecording {
    private(set) var settingID: String?
    @ObservationIgnored private var monitor: Any?

    func start(for settingID: String, typed: @escaping @MainActor (KeyCombo) -> Void) {
        stop()
        self.settingID = settingID
        Keyboard.shared.pauseShortcuts(true)
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let combo = KeyCombo(keyCode: Int(event.keyCode), modifiers: KeyModifiers(eventFlags: event.modifierFlags))
            MainActor.assumeIsolated { typed(combo) }
            return nil
        }
    }

    func stop() {
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
        self.monitor = nil
        settingID = nil
        Keyboard.shared.pauseShortcuts(false)
    }
}
