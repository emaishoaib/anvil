public enum HIDPPNotification: Equatable, Sendable {
    case controlsHeld(Set<UInt16>)
    case linkRestored

    static let minimumLength = 7
    static let connectionSubID: UInt8 = 0x41
    static let linkLostFlag: UInt8 = 0x40
    static let eventFunctionAndSoftwareID: UInt8 = 0x00
    static let heldControlBytes = 4..<12

    public init?(report: [UInt8], from device: UInt8, controlsFeature: UInt8?) {
        guard report.count >= Self.minimumLength, report[1] == device else { return nil }
        if report[2] == Self.connectionSubID {
            guard report[4] & Self.linkLostFlag == 0 else { return nil }
            self = .linkRestored
            return
        }
        guard let controlsFeature, report[2] == controlsFeature, report[3] == Self.eventFunctionAndSoftwareID else { return nil }
        let end = min(report.count, Self.heldControlBytes.upperBound)
        let controls = stride(from: Self.heldControlBytes.lowerBound, to: end - 1, by: 2).map {
            UInt16(report[$0]) << 8 | UInt16(report[$0 + 1])
        }
        self = .controlsHeld(Set(controls.filter { $0 != 0 }))
    }
}
