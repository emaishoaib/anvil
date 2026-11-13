import Testing
@testable import MouseKit

struct HIDPPTests {
    @Test func aRequestIsALongReportWithItsFunctionAndSoftwareID() {
        let report = HIDPPRequest.featureIndex(of: 0x0005, on: 2).report
        #expect(report.count == 20)
        #expect(Array(report.prefix(6)) == [0x11, 0x02, 0x00, 0x0B, 0x00, 0x05])
        #expect(report.dropFirst(6).allSatisfy { $0 == 0 })
    }

    @Test func anAnswerToTheRequestGivesItsParameters() {
        let request = HIDPPRequest.featureIndex(of: 0x0005, on: 2)
        let report: [UInt8] = [0x11, 0x02, 0x00, 0x0B, 0x07, 0x00, 0x01] + Array(repeating: 0, count: 13)
        #expect(HIDPPReply(report: report, answering: request)?.parameters?.first == 0x07)
    }

    @Test func anErrorAboutTheRequestIsAnError() {
        let request = HIDPPRequest.protocolVersion(of: 4)
        let newerError: [UInt8] = [0x11, 0x04, 0xFF, 0x00, 0x1B, 0x05] + Array(repeating: 0, count: 14)
        let olderError: [UInt8] = [0x10, 0x04, 0x8F, 0x00, 0x1B, 0x09, 0x00]
        #expect(HIDPPReply(report: newerError, answering: request) == .error(0x05))
        #expect(HIDPPReply(report: olderError, answering: request) == .error(0x09))
    }

    @Test func aReportForAnotherDeviceOrAnotherAppIsIgnored() {
        let request = HIDPPRequest.protocolVersion(of: 1)
        let otherDevice: [UInt8] = [0x11, 0x02, 0x00, 0x1B, 0x04, 0x05]
        let otherApp: [UInt8] = [0x11, 0x01, 0x00, 0x1C, 0x04, 0x05]
        #expect(HIDPPReply(report: otherDevice, answering: request) == nil)
        #expect(HIDPPReply(report: otherApp, answering: request) == nil)
    }

    @Test func aNameIsJoinedFromItsPartsAndCutToItsLength() {
        let parts: [[UInt8]] = [Array("MX Master 3S".utf8) + [0, 0, 0, 0], Array(repeating: 0, count: 16)]
        #expect(LogitechDevice.name(from: parts, length: 12) == "MX Master 3S")
    }
}
