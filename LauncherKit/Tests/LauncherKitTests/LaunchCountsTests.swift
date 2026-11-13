import Foundation
import Testing
@testable import LauncherKit

struct LaunchCountsTests {
    let safari = InstalledApp(url: URL(filePath: "/Applications/Safari.app"))

    @Test func anAppNeverOpenedHasACountOfZero() {
        #expect(LaunchCounts().count(for: safari) == 0)
    }

    @Test func recordingAnAppAddsOneToItsCount() {
        var counts = LaunchCounts()
        counts.record(safari)
        counts.record(safari)
        #expect(counts.count(for: safari) == 2)
    }

    @Test func countsAreKeptByThePathOfTheApp() {
        var counts = LaunchCounts()
        counts.record(safari)
        #expect(counts.byPath == ["/Applications/Safari.app": 1])
    }
}
