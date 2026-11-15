import Testing
@testable import MouseKit

struct SensorDPITests {
    let current: [UInt8] = [0x00, 0x07, 0xD0, 0x03, 0xE8]

    @Test func askingForTheAcceptedDPIsAsksAboutTheFirstSensor() {
        let report = HIDPPRequest.dpiList(of: 0xFF, dpiFeature: 0x0A).report
        #expect(Array(report.prefix(5)) == [0x11, 0xFF, 0x0A, 0x1B, 0x00])
    }

    @Test func askingForTheCurrentDPIUsesFunctionTwo() {
        let report = HIDPPRequest.dpi(of: 0xFF, dpiFeature: 0x0A).report
        #expect(Array(report.prefix(5)) == [0x11, 0xFF, 0x0A, 0x2B, 0x00])
    }

    @Test func theCurrentDPIComesFromTheSecondAndThirdBytes() {
        let list: [UInt8] = [0x00, 0x01, 0x90, 0x00, 0x00]
        #expect(SensorDPI(current: current, list: list)?.current == 2000)
    }

    @Test func twoValuesWithAStepBetweenThemStandForEveryStepInTheRange() {
        let list: [UInt8] = [0x00, 0x00, 0xC8, 0xE0, 0x32, 0x1F, 0x40, 0x00, 0x00]
        let dpi = SensorDPI(current: current, list: list)
        #expect(dpi?.lowest == 200)
        #expect(dpi?.highest == 8000)
        #expect(dpi?.choices.count == 157)
        #expect(dpi?.choices.prefix(3) == [200, 250, 300])
    }

    @Test func aPlainListIsReadAsItIs() {
        let list: [UInt8] = [0x00, 0x01, 0x90, 0x03, 0x20, 0x06, 0x40, 0x00, 0x00]
        #expect(SensorDPI(current: current, list: list)?.choices == [400, 800, 1600])
    }

    @Test func noCurrentDPIOrNoAcceptedDPIsGivesNothing() {
        #expect(SensorDPI(current: [0x00, 0x00, 0x00], list: [0x00, 0x01, 0x90]) == nil)
        #expect(SensorDPI(current: current, list: [0x00, 0x00, 0x00]) == nil)
        #expect(SensorDPI(current: [0x00], list: [0x00, 0x01, 0x90]) == nil)
    }
}
