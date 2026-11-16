import Foundation
import IOKit.hid
import MouseKit
import os

extension Logger {
    /// Anvil's log of Logitech devices: channels appearing and going, each search for devices, the settings sent to them, reconnects, and requests that fail. Read it live with `log stream --level info --predicate 'subsystem == "com.mashoaib.anvil"'`.
    nonisolated static let logitech = Logger(subsystem: "com.mashoaib.anvil", category: "logitech")
}

extension HIDPPChannel {
    /// A short name for the channel in the log, the start of its id.
    var logName: String { String(id.prefix(8)) }

    /// The product name and transport macOS reports for the channel's device, such as "MX Master 3S over Bluetooth Low Energy".
    var logDevice: String {
        let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "Unknown device"
        let transport = IOHIDDeviceGetProperty(device, kIOHIDTransportKey as CFString) as? String ?? "an unknown transport"
        return "\(product) over \(transport)"
    }
}

extension HIDPPRequest {
    /// The request's first bytes in hex, enough to tell which device, feature and function it was for.
    var logBytes: String {
        Array(report.prefix(7)).logHex
    }
}

extension [UInt8] {
    /// The bytes in hex, separated by spaces, such as "02 FF 32".
    var logHex: String {
        map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}
