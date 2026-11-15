/// A Logitech device's battery as its Unified Battery feature reports it: how full it is, as a percentage, and whether it is plugged in. A device that cannot measure its charge as a percentage reports none, so its status is not read.
public struct BatteryStatus: Equatable, Sendable {
    static let percentages: ClosedRange<UInt8> = 1...100
    static let pluggedInChargingStatuses: ClosedRange<UInt8> = 1...3

    public let percentage: Int
    public let isPluggedIn: Bool

    public init(percentage: Int, isPluggedIn: Bool) {
        self.percentage = percentage
        self.isPluggedIn = isPluggedIn
    }

    public init?(parameters: [UInt8]) {
        guard parameters.count >= 3, Self.percentages.contains(parameters[0]) else { return nil }
        self.init(percentage: Int(parameters[0]), isPluggedIn: Self.pluggedInChargingStatuses.contains(parameters[2]))
    }
}
