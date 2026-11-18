import AppKit
import AVFoundation
import Observation

/// Listens to the microphone between two presses of the listening shortcut. The first press starts listening once the microphone is allowed, and the second stops it and keeps what was heard. Presses while it is still starting or stopping are ignored. If the microphone is not allowed, or speech cannot be turned into text in the Mac's language, it beeps and stays quiet.
@MainActor @Observable final class Listener {
    static let shared = Listener()

    private(set) var state = ListenerState.idle
    private(set) var heard = ""

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
        heard = await recording.stop()
        state = .idle
    }
}

enum ListenerState {
    case idle
    case starting
    case listening(SpeechRecording)
    case stopping
}
