import AppKit
import AVFoundation
import Observation

/// Listens to the microphone between two presses of the listening shortcut. The first press starts listening once the microphone is allowed, and the second stops it and sends what was heard to Claude through the search bar. Presses while it is still starting or stopping are ignored. If the microphone is not allowed, speech cannot be turned into text in the Mac's language, or nothing was heard, it beeps.
@MainActor @Observable final class Listener {
    static let shared = Listener()

    private(set) var state = ListenerState.idle

    var isListening: Bool {
        guard case .listening = state else { return false }
        return true
    }

    func toggle() {
        switch state {
        case .idle:
            state = .starting
            Task { await start() }
        case .listening(let recording):
            state = .stopping
            Task { await stop(recording) }
        case .starting, .stopping:
            break
        }
    }

    private func start() async {
        guard await AVCaptureDevice.requestAccess(for: .audio), let recording = try? await SpeechRecording.start() else {
            state = .idle
            return NSSound.beep()
        }
        state = .listening(recording)
    }

    private func stop(_ recording: SpeechRecording) async {
        let said = await recording.stop()
        state = .idle
        guard !said.isEmpty else { return NSSound.beep() }
        SearchBar.shared.sendSpoken(said)
    }
}

enum ListenerState {
    case idle
    case starting
    case listening(SpeechRecording)
    case stopping
}
