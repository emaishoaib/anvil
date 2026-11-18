import AVFoundation
import Foundation
import Speech

/// One stretch of listening. The microphone's audio goes to Apple's SpeechAnalyzer, which turns it into text on the Mac with models it downloads from Apple once, so no audio leaves the Mac. Only finished phrases are kept. Stopping ends the audio and waits for the phrase still being heard to finish, then joins the phrases into what was said.
final class SpeechRecording {
    private let analyzer: SpeechAnalyzer
    private let capture: CaptureInputSequenceProvider
    private let audio: AsyncStream<AnalyzerInput>.Continuation
    private let phrases: Task<[String], Never>

    private init(analyzer: SpeechAnalyzer, capture: CaptureInputSequenceProvider, audio: AsyncStream<AnalyzerInput>.Continuation, phrases: Task<[String], Never>) {
        self.analyzer = analyzer
        self.capture = capture
        self.audio = audio
        self.phrases = phrases
    }

    static func start() async throws -> SpeechRecording {
        guard let microphone = AVCaptureDevice.default(for: .audio), let locale = await SpeechTranscriber.supportedLocale(equivalentTo: .current) else { throw SpeechRecordingError.unavailable }
        let transcriber = SpeechTranscriber(locale: locale, preset: .transcription)
        try await installModels(for: transcriber, locale: locale)
        let capture = try await CaptureInputSequenceProvider.providerWithSession(from: microphone, compatibleWith: [transcriber])
        let (inputs, audio) = AsyncStream.makeStream(of: AnalyzerInput.self)
        forward(capture.analyzerInputs, to: audio)
        let analyzer = SpeechAnalyzer(modules: [transcriber])
        let phrases = Task { await finishedPhrases(of: transcriber) }
        try await analyzer.start(inputSequence: inputs)
        capture.captureSession.startRunning()
        return SpeechRecording(analyzer: analyzer, capture: capture, audio: audio, phrases: phrases)
    }

    func stop() async -> String {
        capture.captureSession.stopRunning()
        audio.finish()
        try? await analyzer.finalizeAndFinishThroughEndOfInput()
        return await phrases.value.joined(separator: " ")
    }

    /// Passes the microphone's audio on through a stream Anvil can end, since the analyzer only finishes its last phrase once its input has ended.
    private static func forward(_ microphone: some AsyncSequence<AnalyzerInput, any Error> & Sendable, to audio: AsyncStream<AnalyzerInput>.Continuation) {
        Task {
            do {
                for try await input in microphone { audio.yield(input) }
            } catch {}
            audio.finish()
        }
    }

    private static func installModels(for transcriber: SpeechTranscriber, locale: Locale) async throws {
        _ = try? await AssetInventory.reserve(locale: locale)
        try await AssetInventory.assetInstallationRequest(supporting: [transcriber])?.downloadAndInstall()
    }

    private static func finishedPhrases(of transcriber: SpeechTranscriber) async -> [String] {
        var phrases: [String] = []
        do {
            for try await result in transcriber.results where result.isFinal {
                let phrase = String(result.text.characters).trimmingCharacters(in: .whitespacesAndNewlines)
                if !phrase.isEmpty { phrases.append(phrase) }
            }
        } catch {}
        return phrases
    }
}

enum SpeechRecordingError: Error {
    case unavailable
}
