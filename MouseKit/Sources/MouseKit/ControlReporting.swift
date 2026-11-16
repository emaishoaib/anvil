/// How one control on a Logitech mouse reports its presses, as its Reprogrammable Controls feature (0x1B04) reads it: handled by the mouse itself, or diverted to Anvil as HID++ messages.
public struct ControlReporting: Equatable, Sendable {
    static let flagsByte = 2
    static let divertedFlag: UInt8 = 0x01

    public let isDiverted: Bool

    public init(isDiverted: Bool) {
        self.isDiverted = isDiverted
    }

    public init?(parameters: [UInt8]) {
        guard parameters.count > Self.flagsByte else { return nil }
        self.init(isDiverted: parameters[Self.flagsByte] & Self.divertedFlag != 0)
    }
}
