import Foundation

public struct KeySwap: Identifiable, Hashable, Codable, Sendable {
    private static let keyboardUsagePage: Int64 = 0x7_0000_0000

    public var id: UUID
    public var first: Int
    public var second: Int

    public init(id: UUID = UUID(), first: Int, second: Int) {
        self.id = id
        self.first = first
        self.second = second
    }

    public static func userKeyMapping(for swaps: [KeySwap]) -> String {
        let pairs = swaps.flatMap { [($0.first, $0.second), ($0.second, $0.first)] }
        let entries = pairs.map { source, destination in
            #"{"HIDKeyboardModifierMappingSrc":\#(keyboardUsagePage | Int64(source)),"HIDKeyboardModifierMappingDst":\#(keyboardUsagePage | Int64(destination))}"#
        }
        return #"{"UserKeyMapping":[\#(entries.joined(separator: ","))]}"#
    }
}
