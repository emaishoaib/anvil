import Testing
@testable import MouseKit

struct WheelModeTests {
    @Test func oneReportPerNotchDropsOnlyTheHighResolution() {
        let mode: WheelMode = [.highResolution, .inverted]
        #expect(mode.oneReportPerNotch == .inverted)
    }

    @Test func settingTheWheelModeSendsItsByte() {
        let report = HIDPPRequest.setWheelMode([.inverted], of: 0xFF, wheelFeature: 0x0E).report
        #expect(Array(report.prefix(5)) == [0x11, 0xFF, 0x0E, 0x2B, 0x04])
    }

    @Test func askingForTheWheelModeHasNoParameters() {
        let report = HIDPPRequest.wheelMode(of: 0xFF, wheelFeature: 0x0E).report
        #expect(Array(report.prefix(4)) == [0x11, 0xFF, 0x0E, 0x1B])
        #expect(report.dropFirst(4).allSatisfy { $0 == 0 })
    }
}
