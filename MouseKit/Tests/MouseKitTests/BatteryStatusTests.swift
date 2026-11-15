import Testing
@testable import MouseKit

struct BatteryStatusTests {
    @Test func askingForTheBatteryUsesFunctionOne() {
        let report = HIDPPRequest.batteryStatus(of: 0xFF, batteryFeature: 0x08).report
        #expect(Array(report.prefix(4)) == [0x11, 0xFF, 0x08, 0x1B])
        #expect(report.dropFirst(4).allSatisfy { $0 == 0 })
    }

    @Test func aStatusIsReadAsAPercentageAndWhetherItIsPluggedIn() {
        #expect(BatteryStatus(parameters: [85, 0x04, 0x00, 0x00]) == BatteryStatus(percentage: 85, isPluggedIn: false))
        #expect(BatteryStatus(parameters: [40, 0x04, 0x01, 0x01]) == BatteryStatus(percentage: 40, isPluggedIn: true))
        #expect(BatteryStatus(parameters: [100, 0x08, 0x03, 0x01]) == BatteryStatus(percentage: 100, isPluggedIn: true))
    }

    @Test func aStatusWithoutAUsablePercentageIsNotRead() {
        #expect(BatteryStatus(parameters: [0, 0x08, 0x00]) == nil)
        #expect(BatteryStatus(parameters: [101, 0x08, 0x00]) == nil)
        #expect(BatteryStatus(parameters: [85]) == nil)
    }

    @Test func aBatteryChangeIsReported() {
        let report: [UInt8] = [0x11, 0xFF, 0x08, 0x00, 85, 0x04, 0x00, 0x00] + Array(repeating: 0, count: 12)
        let notification = HIDPPNotification(report: report, from: 0xFF, controlsFeature: 0x09, wirelessStatusFeature: 0x05, batteryFeature: 0x08)
        #expect(notification == .batteryChanged(BatteryStatus(percentage: 85, isPluggedIn: false)))
    }

    @Test func aReplyFromTheBatteryFeatureIsNotAChange() {
        let reply: [UInt8] = [0x11, 0xFF, 0x08, 0x1B, 85, 0x04, 0x00, 0x00] + Array(repeating: 0, count: 12)
        #expect(HIDPPNotification(report: reply, from: 0xFF, controlsFeature: 0x09, wirelessStatusFeature: 0x05, batteryFeature: 0x08) == nil)
    }
}
