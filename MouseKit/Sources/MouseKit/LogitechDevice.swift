public enum LogitechDeviceKind: UInt8, Sendable {
    case keyboard, remoteControl, numpad, mouse, trackpad, trackball, presenter, receiver

    public var name: String {
        switch self {
        case .keyboard: "Keyboard"
        case .remoteControl: "Remote control"
        case .numpad: "Number pad"
        case .mouse: "Mouse"
        case .trackpad: "Trackpad"
        case .trackball: "Trackball"
        case .presenter: "Presenter"
        case .receiver: "Receiver"
        }
    }
}

public struct LogitechDevice: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let kind: LogitechDeviceKind?
    public let deviceIndex: UInt8
    public let controlsFeature: UInt8?
    public let wheelFeature: UInt8?
    public let wirelessStatusFeature: UInt8?
    public let smartShiftFeature: SmartShiftFeature?
    public let batteryFeature: UInt8?

    public init(
        channel: String,
        name: String,
        kind: LogitechDeviceKind?,
        deviceIndex: UInt8,
        controlsFeature: UInt8? = nil,
        wheelFeature: UInt8? = nil,
        wirelessStatusFeature: UInt8? = nil,
        smartShiftFeature: SmartShiftFeature? = nil,
        batteryFeature: UInt8? = nil
    ) {
        id = Self.id(channel: channel, deviceIndex: deviceIndex)
        self.name = name
        self.kind = kind
        self.deviceIndex = deviceIndex
        self.controlsFeature = controlsFeature
        self.wheelFeature = wheelFeature
        self.wirelessStatusFeature = wirelessStatusFeature
        self.smartShiftFeature = smartShiftFeature
        self.batteryFeature = batteryFeature
    }

    public static func id(channel: String, deviceIndex: UInt8) -> String {
        "\(channel)/\(deviceIndex)"
    }

    public var isOnAReceiver: Bool { deviceIndex != HIDPPRequest.directDeviceIndex }

    public static func name(from parts: [[UInt8]], length: Int) -> String {
        let bytes = parts.flatMap { $0 }.prefix(length)
        return String(decoding: bytes, as: UTF8.self)
    }
}
