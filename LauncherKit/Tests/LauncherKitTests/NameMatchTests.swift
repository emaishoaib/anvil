import Testing
@testable import LauncherKit

struct NameMatchTests {
    func matchedParts(of text: String, query: String) -> [String] {
        NameMatch.matchedWordStarts(in: text, query: query).map { String(text[$0]) }
    }

    @Test func eachQueryWordMarksTheStartOfTheWordsItBegins() {
        #expect(matchedParts(of: "tax.service.gov.uk", query: "asig uk gov") == ["gov", "uk"])
    }

    @Test func onlyTheTypedPartOfAWordIsMarked() {
        #expect(matchedParts(of: "tax.service.gov.uk", query: "serv") == ["serv"])
    }

    @Test func theLongestQueryWordWinsWhenSeveralBeginTheSameWord() {
        #expect(matchedParts(of: "tax.service.gov.uk", query: "ta tax") == ["tax"])
    }

    @Test func matchingIgnoresCase() {
        #expect(matchedParts(of: "github.com", query: "GIT") == ["git"])
    }

    @Test func aQueryInsideAWordMarksNothing() {
        #expect(matchedParts(of: "github.com", query: "hub").isEmpty)
    }
}
