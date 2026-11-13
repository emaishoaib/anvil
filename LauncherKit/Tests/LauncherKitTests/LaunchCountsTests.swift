import Foundation
import Testing
@testable import LauncherKit

struct LaunchCountsTests {
    let safari = "/Applications/Safari.app"

    @Test func somethingNeverOpenedHasACountOfZero() {
        #expect(LaunchCounts().count(for: safari) == 0)
    }

    @Test func recordingAKeyAddsOneToItsCount() {
        var counts = LaunchCounts()
        counts.record(safari)
        counts.record(safari)
        #expect(counts.count(for: safari) == 2)
    }

    @Test func appsAreCountedByTheirPathAndCommandsByTheirName() {
        let app = SearchResult.app(InstalledApp(url: URL(filePath: safari)))
        #expect(app.launchKey == safari)
        #expect(SearchResult.command(.defineWord).launchKey == "command:defineWord")
    }
}
