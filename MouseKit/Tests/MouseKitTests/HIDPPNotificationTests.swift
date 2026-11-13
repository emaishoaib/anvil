import Testing
@testable import MouseKit

struct HIDPPNotificationTests {
    @Test func divertingAControlAsksForDivertedReporting() {
        let report = HIDPPRequest.reporting(of: 0x00C3, on: 0xFF, controlsFeature: 0x09, diverted: true).report
        #expect(Array(report.prefix(9)) == [0x11, 0xFF, 0x09, 0x3B, 0x00, 0xC3, 0x03, 0x00, 0x00])
    }

    @Test func handingAControlBackAsksForNormalReporting() {
        let report = HIDPPRequest.reporting(of: 0x00C3, on: 0xFF, controlsFeature: 0x09, diverted: false).report
        #expect(report[6] == 0x02)
    }

    @Test func aHeldGestureButtonIsReported() {
        let report: [UInt8] = [0x11, 0xFF, 0x09, 0x00, 0x00, 0xC3] + Array(repeating: 0, count: 14)
        #expect(HIDPPNotification(report: report, from: 0xFF, controlsFeature: 0x09) == .controlsHeld([0x00C3]))
    }

    @Test func lettingGoReportsNoHeldControls() {
        let report: [UInt8] = [0x11, 0xFF, 0x09, 0x00] + Array(repeating: 0, count: 16)
        #expect(HIDPPNotification(report: report, from: 0xFF, controlsFeature: 0x09) == .controlsHeld([]))
    }

    @Test func aReplyFromTheControlsFeatureIsNotAPress() {
        let reply: [UInt8] = [0x11, 0xFF, 0x09, 0x3B, 0x00, 0xC3, 0x03] + Array(repeating: 0, count: 13)
        #expect(HIDPPNotification(report: reply, from: 0xFF, controlsFeature: 0x09) == nil)
    }

    @Test func aDeviceReconnectingToItsReceiverIsReported() {
        let connected: [UInt8] = [0x10, 0x02, 0x41, 0x10, 0x02, 0x34, 0xB0]
        let disconnected: [UInt8] = [0x10, 0x02, 0x41, 0x10, 0x42, 0x34, 0xB0]
        #expect(HIDPPNotification(report: connected, from: 0x02, controlsFeature: nil) == .linkRestored)
        #expect(HIDPPNotification(report: disconnected, from: 0x02, controlsFeature: nil) == nil)
    }
}
