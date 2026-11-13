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

    public init(channel: String, name: String, kind: LogitechDeviceKind?, deviceIndex: UInt8) {
        id = "\(channel)/\(deviceIndex)"
        self.name = name
        self.kind = kind
        self.deviceIndex = deviceIndex
    }

    public var isOnAReceiver: Bool { deviceIndex != HIDPPRequest.directDeviceIndex }

    public static func name(from parts: [[UInt8]], length: Int) -> String {
        let bytes = parts.flatMap { $0 }.prefix(length)
        return String(decoding: bytes, as: UTF8.self)
    }
}
