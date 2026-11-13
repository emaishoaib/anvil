import MouseKit
import SwiftUI

struct LogitechSection: View {
    private let logitech = LogitechDevices.shared

    var body: some View {
        Section("Logitech Devices") {
            if logitech.devices.isEmpty {
                Text("None found yet").foregroundStyle(.secondary)
            }
            ForEach(logitech.devices) { device in
                LabeledContent(device.name, value: Self.summary(of: device))
            }
        }
    }

    private static func summary(of device: LogitechDevice) -> String {
        let kind = device.kind?.name ?? "Device"
        return device.isOnAReceiver ? "\(kind), through a receiver" : "\(kind), connected directly"
    }
}
