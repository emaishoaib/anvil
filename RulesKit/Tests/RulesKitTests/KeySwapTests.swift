import Foundation
import Testing
@testable import RulesKit

struct KeySwapTests {
    @Test func aSwapMapsEachKeyToTheOtherOnTheKeyboardUsagePage() throws {
        let mapping = KeySwap.userKeyMapping(for: [KeySwap(first: 0x64, second: 0x35)])
        let parsed = try JSONSerialization.jsonObject(with: Data(mapping.utf8)) as? [String: [[String: Int64]]]
        #expect(parsed?["UserKeyMapping"] == [
            ["HIDKeyboardModifierMappingSrc": 0x700000064, "HIDKeyboardModifierMappingDst": 0x700000035],
            ["HIDKeyboardModifierMappingSrc": 0x700000035, "HIDKeyboardModifierMappingDst": 0x700000064],
        ])
    }

    @Test func noSwapsClearTheMapping() {
        #expect(KeySwap.userKeyMapping(for: []) == #"{"UserKeyMapping":[]}"#)
    }
}
