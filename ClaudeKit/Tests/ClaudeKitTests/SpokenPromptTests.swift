import Testing
@testable import ClaudeKit

struct SpokenPromptTests {
    private static func spoken(_ said: String, unnamed: SpokenPrompt.Session = .new) -> SpokenPrompt {
        SpokenPrompt(said, newSessionPhrase: "new session", lastSessionPhrase: "last session", unnamed: unnamed)
    }

    @Test func sayingTheNewSessionPhraseAsksForANewOneAndIsDropped() {
        let spoken = Self.spoken("New session. Why does the build fail?", unnamed: .last)
        #expect(spoken.session == .new)
        #expect(spoken.text == "Why does the build fail?")
    }

    @Test func sayingTheLastSessionPhraseMeansTheLastOneAndIsDropped() {
        let spoken = Self.spoken("last session, try it again")
        #expect(spoken.session == .last)
        #expect(spoken.text == "try it again")
    }

    @Test func namingNoSessionGoesWhereUnnamedSpeechIsSetToGo() {
        #expect(Self.spoken("  Explain this function. ", unnamed: .new) == SpokenPrompt("Explain this function.", newSessionPhrase: "", lastSessionPhrase: "", unnamed: .new))
        #expect(Self.spoken("Explain this function.", unnamed: .last).session == .last)
    }

    @Test func namingNoSessionKeepsEverythingThatWasSaid() {
        #expect(Self.spoken("  Explain this function. ").text == "Explain this function.")
    }

    @Test func otherPhrasesCanBeChosen() {
        let spoken = SpokenPrompt("Fresh start: plan the release", newSessionPhrase: "fresh start", lastSessionPhrase: "carry on", unnamed: .last)
        #expect(spoken.session == .new)
        #expect(spoken.text == "plan the release")
    }

    @Test func anEmptyPhraseNeverMatches() {
        let spoken = SpokenPrompt("Plan the release", newSessionPhrase: " ", lastSessionPhrase: "", unnamed: .last)
        #expect(spoken.session == .last)
        #expect(spoken.text == "Plan the release")
    }

    @Test func thePhraseOnlyCountsAtTheStart() {
        let spoken = Self.spoken("Open a new session for this", unnamed: .last)
        #expect(spoken.session == .last)
        #expect(spoken.text == "Open a new session for this")
    }

    @Test func thePhraseOnlyCountsAsWholeWords() {
        let spoken = Self.spoken("New sessions are slow", unnamed: .last)
        #expect(spoken.session == .last)
        #expect(spoken.text == "New sessions are slow")
    }

    @Test func sayingOnlyThePhraseLeavesNothingToSend() {
        let spoken = Self.spoken("New session.")
        #expect(spoken.session == .new)
        #expect(spoken.text.isEmpty)
    }
}
