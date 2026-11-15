import MouseKit
import SwiftUI

struct LogitechSection: View {
    private let logitech = LogitechDevices.shared

    var body: some View {
        if logitech.devices.isEmpty {
            Section("Logitech Devices") {
                Text("None found yet").foregroundStyle(.secondary)
            }
        }
        ForEach(logitech.devices) { device in
            Section {
                LabeledContent("Connection", value: Self.connection(of: device))
                if let dpi = logitech.dpis[device.id] {
                    DPIRow(dpi: dpi)
                }
            } header: {
                DeviceHeader(device: device, battery: logitech.batteries[device.id])
            }
        }
    }

    private static func connection(of device: LogitechDevice) -> String {
        let kind = device.kind?.name ?? "Device"
        return device.isOnAReceiver ? "\(kind), through a receiver" : "\(kind), connected directly"
    }
}

private struct DPIRow: View {
    let dpi: SensorDPI

    var body: some View {
        LabeledContent {
            Text(dpi.current, format: .number)
                .monospacedDigit()
        } label: {
            Text("DPI")
            Text("Accepts \(dpi.lowest) to \(dpi.highest)")
        }
    }
}

private struct DeviceHeader: View {
    let device: LogitechDevice
    let battery: BatteryStatus?

    var body: some View {
        HStack {
            Text(device.name)
            Spacer()
            if let battery {
                Label("\(battery.percentage)%", systemImage: Self.symbol(for: battery))
                    .monospacedDigit()
            }
        }
    }

    private static func symbol(for battery: BatteryStatus) -> String {
        guard !battery.isPluggedIn else { return "battery.100percent.bolt" }
        let nearestQuarter = Int((Double(battery.percentage) / 25).rounded()) * 25
        return "battery.\(nearestQuarter)percent"
    }
}
