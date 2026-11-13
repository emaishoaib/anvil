/// The MX Master wheel's SmartShift: whether the wheel is in ratchet mode or free spin, and how fast a flick has to be before the ratchet disengages.
public struct SmartShift: Equatable, Sendable {
    public enum Mode: UInt8, Sendable {
        case freeSpin = 1
        case ratchet = 2
    }

    public static let neverDisengages: UInt8 = 0xFF
    public static let ratchetAlwaysEngaged = SmartShift(mode: .ratchet, disengageSpeed: neverDisengages)

    public let mode: Mode
    public let disengageSpeed: UInt8

    public init(mode: Mode, disengageSpeed: UInt8) {
        self.mode = mode
        self.disengageSpeed = disengageSpeed
    }

    public init?(parameters: [UInt8]) {
        guard parameters.count >= 2, let mode = Mode(rawValue: parameters[0]) else { return nil }
        self.init(mode: mode, disengageSpeed: parameters[1])
    }

    var parameters: [UInt8] { [mode.rawValue, disengageSpeed] }
}
