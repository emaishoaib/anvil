/// How a Logitech thumb wheel reports its turns, as its Thumbwheel feature (0x2150) reads and sets it: as ordinary sideways scrolling, or diverted to Anvil as HID++ messages, and whether its direction is inverted on the mouse itself.
public struct ThumbWheelReporting: Equatable, Sendable {
    public let isDiverted: Bool
    public let isInverted: Bool

    public init(isDiverted: Bool, isInverted: Bool) {
        self.isDiverted = isDiverted
        self.isInverted = isInverted
    }

    public init?(parameters: [UInt8]) {
        guard parameters.count >= 2 else { return nil }
        self.init(isDiverted: parameters[0] != 0, isInverted: parameters[1] != 0)
    }

    var parameters: [UInt8] { [isDiverted ? 1 : 0, isInverted ? 1 : 0] }
}
