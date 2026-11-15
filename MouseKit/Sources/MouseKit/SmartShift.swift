/// The MX Master wheel's SmartShift: whether the wheel is in ratchet mode or free spin, and how fast a flick has to be before the ratchet disengages. The mouse's reply also carries its own default disengage speed, as a third byte. A disengage speed is chosen from 1 to 50, as Solaar offers it, and the top of that range stands for a ratchet that never disengages.
public struct SmartShift: Equatable, Sendable {
    public enum Mode: UInt8, Sendable {
        case freeSpin = 1
        case ratchet = 2
    }

    public static let neverDisengages: UInt8 = 0xFF
    public static let ratchetAlwaysEngaged = SmartShift(mode: .ratchet, disengageSpeed: neverDisengages)
    public static let disengageSpeeds: ClosedRange<Int> = 1...50

    public static func ratchet(disengagingAt speed: Int) -> SmartShift {
        guard speed < disengageSpeeds.upperBound else { return ratchetAlwaysEngaged }
        return SmartShift(mode: .ratchet, disengageSpeed: UInt8(max(speed, disengageSpeeds.lowerBound)))
    }

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

    public static func ratchetDisengagingAtDefaultSpeed(from parameters: [UInt8]) -> SmartShift? {
        guard parameters.count >= 3, parameters[2] != 0 else { return nil }
        return SmartShift(mode: .ratchet, disengageSpeed: parameters[2])
    }

    var parameters: [UInt8] { [mode.rawValue, disengageSpeed] }
}
