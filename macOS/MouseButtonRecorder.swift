import Carbon.HIToolbox
import SwiftUI

/// A button that, once clicked, waits for a press of any mouse button other than the left or right and records its number. Escape stops waiting.
struct MouseButtonRecorder: View {
    let record: (Int) -> Void
    @State private var monitor: Any?

    var body: some View {
        Button(monitor == nil ? "Record a Button" : "Press a mouse button…") {
            if monitor == nil { start() } else { stop() }
        }
        .onDisappear { stop() }
    }

    private func start() {
        Keyboard.shared.pauseShortcuts(true)
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.otherMouseDown, .keyDown]) { event in
            MainActor.assumeIsolated { received(event) }
            return nil
        }
    }

    private func received(_ event: NSEvent) {
        let isButton = event.type == .otherMouseDown
        guard isButton || event.keyCode == kVK_Escape else { return }
        if isButton { record(event.buttonNumber) }
        stop()
    }

    private func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        Keyboard.shared.pauseShortcuts(false)
    }
}
