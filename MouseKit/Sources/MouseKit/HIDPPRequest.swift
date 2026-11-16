public struct HIDPPRequest: Hashable, Sendable {
    /// Whether a request calls a function of a HID++ 2.0 feature on a device, or writes a HID++ 1.0 register on a receiver.
    public enum Addressing: Hashable, Sendable {
        case feature
        case register
    }

    public static let logitechVendorID = 0x046D
    public static let directDeviceIndex: UInt8 = 0xFF
    public static let receiverIndex: UInt8 = 0xFF
    public static let receiverSlots: ClosedRange<UInt8> = 1...6
    public static let deviceNameFeature: UInt16 = 0x0005
    public static let reprogrammableControlsFeature: UInt16 = 0x1B04
    public static let buttonBehindWheelControl: UInt16 = 0x00C4
    public static let wheelFeature: UInt16 = 0x2121
    public static let wirelessStatusFeature: UInt16 = 0x1D4B
    public static let unifiedBatteryFeature: UInt16 = 0x1004
    public static let adjustableDPIFeature: UInt16 = 0x2201
    public static let thumbWheelFeature: UInt16 = 0x2150
    static let firstSensor: UInt8 = 0
    static let divertedReporting: UInt8 = 0x03
    static let undivertedReporting: UInt8 = 0x02
    static let shortReportID: UInt8 = 0x10
    static let shortReportLength = 7
    static let longReportID: UInt8 = 0x11
    static let longReportLength = 20
    static let softwareID: UInt8 = 0x0B
    static let rootFeatureIndex: UInt8 = 0
    static let pingByte: UInt8 = 0x5A
    static let setShortRegister: UInt8 = 0x80
    static let notificationsRegister: UInt8 = 0x00
    static let wirelessNotificationFlags: [UInt8] = [0x00, 0x01, 0x00]

    public let deviceIndex: UInt8
    public let featureIndex: UInt8
    public let function: UInt8
    public let parameters: [UInt8]
    public let addressing: Addressing

    public init(deviceIndex: UInt8, featureIndex: UInt8, function: UInt8, parameters: [UInt8] = [], addressing: Addressing = .feature) {
        self.deviceIndex = deviceIndex
        self.featureIndex = featureIndex
        self.function = function
        self.parameters = parameters
        self.addressing = addressing
    }

    var functionAndSoftwareID: UInt8 {
        switch addressing {
        case .feature: function << 4 | Self.softwareID
        case .register: function
        }
    }

    public var report: [UInt8] {
        let (reportID, length) = switch addressing {
        case .feature: (Self.longReportID, Self.longReportLength)
        case .register: (Self.shortReportID, Self.shortReportLength)
        }
        let header = [reportID, deviceIndex, featureIndex, functionAndSoftwareID]
        let body = Array(parameters.prefix(length - header.count))
        return header + body + Array(repeating: 0, count: length - header.count - body.count)
    }

    /// Asks a receiver to report each device that connects to it or drops off, which it stays quiet about until asked.
    public static let enableWirelessNotifications = HIDPPRequest(
        deviceIndex: receiverIndex,
        featureIndex: setShortRegister,
        function: notificationsRegister,
        parameters: wirelessNotificationFlags,
        addressing: .register
    )

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

    public static func wheelMode(of device: UInt8, wheelFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: wheelFeature, function: 1)
    }

    public static func setWheelMode(_ mode: WheelMode, of device: UInt8, wheelFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: wheelFeature, function: 2, parameters: [mode.rawValue])
    }

    public static func smartShift(of device: UInt8, feature: SmartShiftFeature) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: feature.index, function: feature.version.readFunction)
    }

    public static func setSmartShift(_ smartShift: SmartShift, of device: UInt8, feature: SmartShiftFeature) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: feature.index, function: feature.version.writeFunction, parameters: smartShift.parameters)
    }

    public static func batteryStatus(of device: UInt8, batteryFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: batteryFeature, function: 1)
    }

    public static func dpiList(of device: UInt8, dpiFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: dpiFeature, function: 1, parameters: [firstSensor])
    }

    public static func dpi(of device: UInt8, dpiFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: dpiFeature, function: 2, parameters: [firstSensor])
    }

    public static func setDPI(_ dpi: Int, of device: UInt8, dpiFeature: UInt8) -> HIDPPRequest {
        let value = UInt16(clamping: dpi)
        return HIDPPRequest(deviceIndex: device, featureIndex: dpiFeature, function: 3, parameters: [firstSensor, UInt8(value >> 8), UInt8(value & 0xFF)])
    }

    public static func thumbWheelReporting(of device: UInt8, thumbWheelFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: thumbWheelFeature, function: 1)
    }

    public static func setThumbWheelReporting(_ reporting: ThumbWheelReporting, of device: UInt8, thumbWheelFeature: UInt8) -> HIDPPRequest {
        HIDPPRequest(deviceIndex: device, featureIndex: thumbWheelFeature, function: 2, parameters: reporting.parameters)
    }

    public static func reporting(of control: UInt16, on device: UInt8, controlsFeature: UInt8, diverted: Bool) -> HIDPPRequest {
        HIDPPRequest(
            deviceIndex: device,
            featureIndex: controlsFeature,
            function: 3,
            parameters: [UInt8(control >> 8), UInt8(control & 0xFF), diverted ? divertedReporting : undivertedReporting, 0, 0]
        )
    }
}
