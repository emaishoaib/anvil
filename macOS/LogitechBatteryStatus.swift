import MouseKit
import SwiftUI

/// The battery of a Logitech mouse or keyboard, for the footer's status row. It turns orange when the battery runs low and the device is not charging.
struct LogitechBatteryStatus: View, Identifiable {
    private static let lowPercentage = 20

    let id: String
    let name: String
    let kind: LogitechDeviceKind
    let battery: BatteryStatus

    /// One item for each connected Logitech mouse and keyboard whose battery Anvil has read, keyboards first.
    static func all(in logitech: LogitechDevices = .shared) -> [LogitechBatteryStatus] {
        logitech.devices
            .compactMap { device in
                guard let kind = device.kind, kind == .mouse || kind == .keyboard, let battery = logitech.batteries[device.id] else { return nil }
                return LogitechBatteryStatus(id: device.id, name: device.name, kind: kind, battery: battery)
            }
            .sorted { $0.kind == .keyboard && $1.kind != .keyboard }
    }

    var body: some View {
        StatusItem(symbol: kind == .mouse ? "computermouse" : "keyboard", title: title, emphasis: isLow ? .warning : .quiet)
            .help("\(name) battery: \(title)")
    }

    private var isLow: Bool {
        !battery.isPluggedIn && battery.percentage <= Self.lowPercentage
    }

    private var title: String {
        battery.isPluggedIn ? "\(battery.percentage)%, charging" : "\(battery.percentage)%"
    }
}
