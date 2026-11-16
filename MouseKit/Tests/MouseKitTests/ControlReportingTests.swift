import Testing
@testable import MouseKit

struct ControlReportingTests {
    @Test func askingHowAControlReportsSendsTheControlWithFunctionTwo() {
        let report = HIDPPRequest.controlReporting(of: 0x00C4, on: 0xFF, controlsFeature: 0x09).report
        #expect(Array(report.prefix(6)) == [0x11, 0xFF, 0x09, 0x2B, 0x00, 0xC4])
        #expect(report.dropFirst(6).allSatisfy { $0 == 0 })
    }

    @Test func aReplyWithTheDivertedFlagIsReadAsDiverted() {
        #expect(ControlReporting(parameters: [0x00, 0xC4, 0x01, 0x00, 0x00]) == ControlReporting(isDiverted: true))
        #expect(ControlReporting(parameters: [0x00, 0xC4, 0x03, 0x00, 0x00]) == ControlReporting(isDiverted: true))
    }

    @Test func aReplyWithoutTheDivertedFlagIsReadAsHandledByTheMouse() {
        #expect(ControlReporting(parameters: [0x00, 0xC4, 0x00, 0x00, 0x00]) == ControlReporting(isDiverted: false))
        #expect(ControlReporting(parameters: [0x00, 0xC4, 0x02, 0x00, 0x00]) == ControlReporting(isDiverted: false))
    }

    @Test func aReplyTooShortToHoldTheFlagsIsNotRead() {
        #expect(ControlReporting(parameters: [0x00, 0xC4]) == nil)
    }
}
