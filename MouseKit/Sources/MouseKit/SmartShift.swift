/// The MX Master wheel's ratchet: whether the wheel clicks or spins freely, and how fast a flick has to be before a clicking wheel lets go and spins freely.
public struct SmartShift: Equatable, Sendable {
    public enum Spin: UInt8, Sendable {
        case free = 1
        case ratchet = 2
    }

    public static let neverLetsGo: UInt8 = 0xFF
    public static let alwaysClicking = SmartShift(spin: .ratchet, letGoSpeed: neverLetsGo)

    public let spin: Spin
    public let letGoSpeed: UInt8

    public init(spin: Spin, letGoSpeed: UInt8) {
        self.spin = spin
        self.letGoSpeed = letGoSpeed
    }

    public init?(parameters: [UInt8]) {
        guard parameters.count >= 2, let spin = Spin(rawValue: parameters[0]) else { return nil }
        self.init(spin: spin, letGoSpeed: parameters[1])
    }

    var parameters: [UInt8] { [spin.rawValue, letGoSpeed] }
}
