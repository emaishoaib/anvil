import Carbon.HIToolbox
import SwiftUI

struct ShortcutRecorder: View {
    private static let requiredModifiers: KeyModifiers = [.control, .option, .command]

    let combo: KeyCombo?
    let record: (KeyCombo?) -> Void
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 6) {
            Button {
                if monitor == nil { start() } else { stop() }
            } label: {
                recorderLabel
            }
            if combo != nil && monitor == nil {
                Button("Clear", systemImage: "xmark.circle.fill") { record(nil) }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
            }
        }
        .onDisappear { stop() }
    }

    @ViewBuilder private var recorderLabel: some View {
        if monitor != nil {
            Text("Type a shortcut…")
        } else if let combo {
            KeyCaps(combo: combo)
        } else {
            Text("Record Shortcut")
        }
    }

    private func start() {
        Keyboard.shared.pauseShortcuts(true)
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let combo = KeyCombo(keyCode: Int(event.keyCode), modifiers: KeyModifiers(eventFlags: event.modifierFlags))
            MainActor.assumeIsolated { typed(combo) }
            return nil
        }
    }

    private func typed(_ typedCombo: KeyCombo) {
        if typedCombo.keyCode == kVK_Escape && typedCombo.modifiers.isEmpty { return stop() }
        guard !typedCombo.modifiers.isDisjoint(with: Self.requiredModifiers) else { return NSSound.beep() }
        record(typedCombo)
        stop()
    }

    private func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        Keyboard.shared.pauseShortcuts(false)
    }
}
