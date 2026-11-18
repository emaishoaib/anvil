import Testing
@testable import ClaudeKit

struct SpokenPromptTests {
    @Test func sayingNewSessionAsksForANewOneAndIsDropped() {
        let spoken = SpokenPrompt("New session. Why does the build fail?")
        #expect(spoken.session == .new)
        #expect(spoken.text == "Why does the build fail?")
    }

    @Test func sayingLastSessionMeansTheLastOneAndIsDropped() {
        let spoken = SpokenPrompt("last session, try it again")
        #expect(spoken.session == .last)
        #expect(spoken.text == "try it again")
    }

    @Test func namingNoSessionMeansTheLastOne() {
        let spoken = SpokenPrompt("  Explain this function. ")
        #expect(spoken.session == .last)
        #expect(spoken.text == "Explain this function.")
    }

    @Test func thePhraseOnlyCountsAtTheStart() {
        let spoken = SpokenPrompt("Open a new session for this")
        #expect(spoken.session == .last)
        #expect(spoken.text == "Open a new session for this")
    }

    @Test func thePhraseOnlyCountsAsWholeWords() {
        let spoken = SpokenPrompt("New sessions are slow")
        #expect(spoken.session == .last)
        #expect(spoken.text == "New sessions are slow")
    }

    @Test func sayingOnlyThePhraseLeavesNothingToSend() {
        let spoken = SpokenPrompt("New session.")
        #expect(spoken.session == .new)
        #expect(spoken.text.isEmpty)
    }
}
