public struct HIDPPRequest: Hashable, Sendable {
    public static let logitechVendorID = 0x046D
    public static let directDeviceIndex: UInt8 = 0xFF
    public static let receiverSlots: ClosedRange<UInt8> = 1...6
    public static let deviceNameFeature: UInt16 = 0x0005
    static let longReportID: UInt8 = 0x11
    static let longReportLength = 20
    static let softwareID: UInt8 = 0x0B
    static let rootFeatureIndex: UInt8 = 0
    static let pingByte: UInt8 = 0x5A

    public let deviceIndex: UInt8
    public let featureIndex: UInt8
    public let function: UInt8
    public let parameters: [UInt8]

    public init(deviceIndex: UInt8, featureIndex: UInt8, function: UInt8, parameters: [UInt8] = []) {
        self.deviceIndex = deviceIndex
        self.featureIndex = featureIndex
        self.function = function
        self.parameters = parameters
    }

    var functionAndSoftwareID: UInt8 { function << 4 | Self.softwareID }

    public var report: [UInt8] {
        let header = [Self.longReportID, deviceIndex, featureIndex, functionAndSoftwareID]
        let body = Array(parameters.prefix(Self.longReportLength - header.count))
        return header + body + Array(repeating: 0, count: Self.longReportLength - header.count - body.count)
    }

    public static func protocolVersion(of device: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: rootFeatureIndex, function: 1, parameters: [0, 0, pingByte])
    }

    public static func featureIndex(of feature: UInt16, on device: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: rootFeatureIndex, function: 0, parameters: [UInt8(feature >> 8), UInt8(feature & 0xFF)])
    }

    public static func nameLength(of device: UInt8, nameFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: nameFeature, function: 0)
    }

    public static func namePart(of device: UInt8, nameFeature: UInt8, from offset: Int) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: nameFeature, function: 1, parameters: [UInt8(clamping: offset)])
    }

    public static func kind(of device: UInt8, nameFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: nameFeature, function: 2)
    }
}
