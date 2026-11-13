import Foundation
import Testing
@testable import LauncherKit

struct AppRankingTests {
    let xcode = InstalledApp(url: URL(filePath: "/Applications/Xcode.app"))
    let visualStudioCode = InstalledApp(url: URL(filePath: "/Applications/Visual Studio Code.app"))
    let codeRunner = InstalledApp(url: URL(filePath: "/Applications/CodeRunner.app"))
    let safari = InstalledApp(url: URL(filePath: "/Applications/Safari.app"))

    var apps: [InstalledApp] { [xcode, visualStudioCode, codeRunner, safari] }

    func names(for query: String, launchCounts: LaunchCounts = LaunchCounts()) -> [String] {
        AppRanking.matches(for: query, in: apps, launchCounts: launchCounts).map(\.name)
    }

    @Test func emptyQueryMatchesNothing() {
        #expect(names(for: "  ").isEmpty)
    }

    @Test func appsThatDoNotMatchAreLeftOut() {
        #expect(!names(for: "code").contains("Safari"))
    }

    @Test func betterMatchesComeFirstWhenNothingHasBeenOpened() {
        #expect(names(for: "code") == ["CodeRunner", "Visual Studio Code", "Xcode"])
    }

    @Test func appsOpenedMoreOftenComeFirst() {
        let counts = LaunchCounts([xcode.url.path: 5, visualStudioCode.url.path: 2])
        #expect(names(for: "code", launchCounts: counts) == ["Xcode", "Visual Studio Code", "CodeRunner"])
    }

    @Test func equalMatchesAreAlphabetical() {
        let zed = InstalledApp(url: URL(filePath: "/Applications/Zed.app"))
        let zoom = InstalledApp(url: URL(filePath: "/Applications/zoom.us.app"))
        let names = AppRanking.matches(for: "z", in: [zoom, zed], launchCounts: LaunchCounts()).map(\.name)
        #expect(names == ["Zed", "zoom.us"])
    }
}
