import Testing
@testable import MouseKit

struct SmartShiftTests {
    let enhanced = SmartShiftFeature(index: 0x0F, version: .enhanced)
    let original = SmartShiftFeature(index: 0x0F, version: .original)

    @Test func askingTheEnhancedFeatureUsesFunctionOne() {
        let report = HIDPPRequest.smartShift(of: 0xFF, feature: enhanced).report
        #expect(Array(report.prefix(4)) == [0x11, 0xFF, 0x0F, 0x1B])
        #expect(report.dropFirst(4).allSatisfy { $0 == 0 })
    }

    @Test func askingTheOriginalFeatureUsesFunctionZero() {
        let report = HIDPPRequest.smartShift(of: 0xFF, feature: original).report
        #expect(Array(report.prefix(4)) == [0x11, 0xFF, 0x0F, 0x0B])
    }

    @Test func anAlwaysEngagedRatchetSendsRatchetModeAndNeverDisengages() {
        let report = HIDPPRequest.setSmartShift(.ratchetAlwaysEngaged, of: 0xFF, feature: enhanced).report
        #expect(Array(report.prefix(7)) == [0x11, 0xFF, 0x0F, 0x2B, 0x02, 0xFF, 0x00])
    }

    @Test func theOriginalFeatureIsSetWithFunctionOne() {
        let report = HIDPPRequest.setSmartShift(.ratchetAlwaysEngaged, of: 0xFF, feature: original).report
        #expect(report[3] == 0x1B)
    }

    @Test func aReplyIsReadAsTheModeAndTheDisengageSpeed() {
        #expect(SmartShift(parameters: [0x02, 0x0A, 0x0A]) == SmartShift(mode: .ratchet, disengageSpeed: 10))
        #expect(SmartShift(parameters: [0x01, 0x0A, 0x0A]) == SmartShift(mode: .freeSpin, disengageSpeed: 10))
    }

    @Test func aReplyWithAnUnknownModeIsNotRead() {
        #expect(SmartShift(parameters: [0x00, 0x0A]) == nil)
        #expect(SmartShift(parameters: [0x02]) == nil)
    }

    @Test func theDefaultDisengageSpeedComesFromTheThirdByteOfTheReply() {
        let reply: [UInt8] = [0x02, 0xFF, 0x0A]
        #expect(SmartShift.ratchetDisengagingAtDefaultSpeed(from: reply) == SmartShift(mode: .ratchet, disengageSpeed: 10))
    }

    @Test func aReplyWithoutADefaultDisengageSpeedGivesNone() {
        #expect(SmartShift.ratchetDisengagingAtDefaultSpeed(from: [0x02, 0xFF]) == nil)
        #expect(SmartShift.ratchetDisengagingAtDefaultSpeed(from: [0x02, 0xFF, 0x00]) == nil)
    }
}
