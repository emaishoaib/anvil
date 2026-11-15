import Testing
@testable import MouseKit

struct ThumbWheelTests {
    @Test func askingHowTheThumbWheelReportsUsesFunctionOne() {
        let report = HIDPPRequest.thumbWheelReporting(of: 0xFF, thumbWheelFeature: 0x0C).report
        #expect(Array(report.prefix(4)) == [0x11, 0xFF, 0x0C, 0x1B])
        #expect(report.dropFirst(4).allSatisfy { $0 == 0 })
    }

    @Test func divertingTheThumbWheelSendsDivertedAndTheDirectionWithFunctionTwo() {
        let diverted = ThumbWheelReporting(isDiverted: true, isInverted: false)
        let report = HIDPPRequest.setThumbWheelReporting(diverted, of: 0xFF, thumbWheelFeature: 0x0C).report
        #expect(Array(report.prefix(6)) == [0x11, 0xFF, 0x0C, 0x2B, 0x01, 0x00])
    }

    @Test func aReportingReplyIsReadAsDivertedAndInverted() {
        #expect(ThumbWheelReporting(parameters: [0x01, 0x01, 0x00, 0x00]) == ThumbWheelReporting(isDiverted: true, isInverted: true))
        #expect(ThumbWheelReporting(parameters: [0x00, 0x00]) == ThumbWheelReporting(isDiverted: false, isInverted: false))
        #expect(ThumbWheelReporting(parameters: [0x01]) == nil)
    }

    @Test func aTurnIsReportedWithItsAmountAndPhase() {
        let report: [UInt8] = [0x11, 0xFF, 0x0C, 0x00, 0x00, 0x0F, 0x00, 0x08, 0x02, 0x00] + Array(repeating: 0, count: 10)
        let notification = HIDPPNotification(report: report, from: 0xFF, controlsFeature: 0x09, wirelessStatusFeature: 0x05, thumbWheelFeature: 0x0C)
        #expect(notification == .thumbWheelTurned(ThumbWheelRotation(amount: 15, phase: .turning)))
    }

    @Test func aTurnTheOtherWayHasANegativeAmount() {
        #expect(ThumbWheelRotation(parameters: [0xFF, 0xF1, 0x00, 0x08, 0x01, 0x00])?.amount == -15)
    }

    @Test func aMessageWithAnUnknownPhaseIsNotATurn() {
        #expect(ThumbWheelRotation(parameters: [0x00, 0x0F, 0x00, 0x08, 0x07]) == nil)
        #expect(ThumbWheelRotation(parameters: [0x00, 0x0F]) == nil)
    }

    @Test func aReplyFromTheThumbWheelFeatureIsNotATurn() {
        let reply: [UInt8] = [0x11, 0xFF, 0x0C, 0x1B, 0x01, 0x00, 0x00, 0x00] + Array(repeating: 0, count: 12)
        #expect(HIDPPNotification(report: reply, from: 0xFF, controlsFeature: 0x09, wirelessStatusFeature: 0x05, thumbWheelFeature: 0x0C) == nil)
    }
}
