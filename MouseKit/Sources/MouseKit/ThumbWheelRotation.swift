/// One message from a diverted thumb wheel: how far it turned since the last message, as a signed amount, and where the turn is in its life, from starting through to stopping.
public struct ThumbWheelRotation: Equatable, Sendable {
    public enum Phase: UInt8, Sendable {
        case inactive, starting, turning, stopping
    }

    static let phaseByte = 4

    public let amount: Int
    public let phase: Phase

    public init(amount: Int, phase: Phase) {
        self.amount = amount
        self.phase = phase
    }

    public init?(parameters: [UInt8]) {
        guard parameters.count > Self.phaseByte, let phase = Phase(rawValue: parameters[Self.phaseByte]) else { return nil }
        let amount = Int16(bitPattern: UInt16(parameters[0]) << 8 | UInt16(parameters[1]))
        self.init(amount: Int(amount), phase: phase)
    }
}
