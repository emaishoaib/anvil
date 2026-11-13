import Testing
@testable import LauncherKit

struct RecentWordsTests {
    @Test func theNewestWordComesFirst() {
        var recent = RecentWords()
        recent.record("verge")
        recent.record("tollgate")
        #expect(recent.words == ["tollgate", "verge"])
    }

    @Test func lookingUpAWordAgainMovesItToTheFront() {
        var recent = RecentWords(["tollgate", "verge", "odyssey"])
        recent.record("odyssey")
        #expect(recent.words == ["odyssey", "tollgate", "verge"])
    }

    @Test func aWordInDifferentCaseIsNotListedTwice() {
        var recent = RecentWords(["Verge"])
        recent.record("verge")
        #expect(recent.words == ["verge"])
    }

    @Test func blankWordsAreIgnored() {
        var recent = RecentWords(["verge"])
        recent.record("  ")
        #expect(recent.words == ["verge"])
    }

    @Test func theListStopsAtTheLimit() {
        var recent = RecentWords((1...RecentWords.limit).map { "word\($0)" })
        recent.record("newest")
        #expect(recent.words.count == RecentWords.limit)
        #expect(recent.words.first == "newest")
        #expect(!recent.words.contains("word\(RecentWords.limit)"))
    }
}
