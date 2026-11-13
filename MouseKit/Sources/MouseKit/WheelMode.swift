public struct WheelMode: OptionSet, Hashable, Sendable {
    public static let reportedToHIDPP = WheelMode(rawValue: 1 << 0)
    public static let highResolution = WheelMode(rawValue: 1 << 1)
    public static let inverted = WheelMode(rawValue: 1 << 2)

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public var oneReportPerNotch: WheelMode { subtracting(.highResolution) }
}
