import Foundation
import Testing
@testable import LauncherKit

struct ResultRankingTests {
    let xcode = InstalledApp(url: URL(filePath: "/Applications/Xcode.app"))
    let visualStudioCode = InstalledApp(url: URL(filePath: "/Applications/Visual Studio Code.app"))
    let codeRunner = InstalledApp(url: URL(filePath: "/Applications/CodeRunner.app"))
    let safari = InstalledApp(url: URL(filePath: "/Applications/Safari.app"))
    let daybreak = InstalledApp(url: URL(filePath: "/Applications/Daybreak.app"))

    var candidates: [SearchResult] {
        [xcode, visualStudioCode, codeRunner, safari, daybreak].map(SearchResult.app) + [.command(.defineWord)]
    }

    func names(for query: String, launchCounts: LaunchCounts = LaunchCounts()) -> [String] {
        ResultRanking.matches(for: query, in: candidates, launchCounts: launchCounts).map(\.name)
    }

    @Test func emptyQueryMatchesNothing() {
        #expect(names(for: "  ").isEmpty)
    }

    @Test func resultsThatDoNotMatchAreLeftOut() {
        #expect(!names(for: "code").contains("Safari"))
    }

    @Test func betterMatchesComeFirstWhenNothingHasBeenOpened() {
        #expect(names(for: "code") == ["CodeRunner", "Visual Studio Code", "Xcode"])
    }

    @Test func resultsOpenedMoreOftenComeFirst() {
        let counts = LaunchCounts([xcode.url.path: 5, visualStudioCode.url.path: 2])
        #expect(names(for: "code", launchCounts: counts) == ["Xcode", "Visual Studio Code", "CodeRunner"])
    }

    @Test func commandsAreRankedAlongsideApps() {
        #expect(names(for: "d").prefix(2) == ["Daybreak", "Define Word"])
        let counts = LaunchCounts([LauncherCommand.defineWord.launchKey: 3])
        #expect(names(for: "d", launchCounts: counts).prefix(2) == ["Define Word", "Daybreak"])
    }

    @Test func equalMatchesAreAlphabetical() {
        let zed = InstalledApp(url: URL(filePath: "/Applications/Zed.app"))
        let zoom = InstalledApp(url: URL(filePath: "/Applications/zoom.us.app"))
        let results = ResultRanking.matches(for: "z", in: [.app(zoom), .app(zed)], launchCounts: LaunchCounts())
        #expect(results == [.app(zed), .app(zoom)])
    }
}
