import Testing
@testable import LauncherKit

struct WordSearchTests {
    @Test func theTypedWordComesBeforeItsCompletions() {
        #expect(WordSearch.candidates(typed: "sea", completions: ["search", "seal"]) == ["sea", "search", "seal"])
    }

    @Test func aCompletionMatchingTheTypedWordIsNotRepeated() {
        #expect(WordSearch.candidates(typed: "Sea", completions: ["search", "sea", "seal"]) == ["Sea", "search", "seal"])
    }

    @Test func nothingTypedHasNoCandidates() {
        #expect(WordSearch.candidates(typed: " ", completions: ["so"]).isEmpty)
    }

    @Test func candidatesStopAtTheLimit() {
        let completions = (1...50).map { "s\($0)" }
        #expect(WordSearch.candidates(typed: "s", completions: completions).count == WordSearch.limit)
    }
}
