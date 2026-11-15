import IOBluetooth
import Observation

/// The battery of one earbud of a connected pair of AirPods, or any headphones that report each side on its own.
struct EarbudBattery: Identifiable, Equatable {
    enum Side {
        case left
        case right
    }

    let deviceName: String
    let side: Side
    let percentage: Int

    var id: String { "\(deviceName).\(side)" }
}

/// The left and right battery levels of connected AirPods. macOS does not publish these, so they are read from battery properties on the Bluetooth device that Apple does not document. Should a macOS update remove them, no earbuds are listed and nothing else changes.
@MainActor @Observable final class AirPodsBatteries {
    static let shared = AirPodsBatteries()

    private static let leftKey = "batteryPercentLeft"
    private static let rightKey = "batteryPercentRight"

    private(set) var earbuds: [EarbudBattery] = []

    func refresh() {
        let devices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] ?? []
        let read = devices.filter { $0.isConnected() }.flatMap(Self.earbuds)
        guard read != earbuds else { return }
        earbuds = read
    }

    private static func earbuds(of device: IOBluetoothDevice) -> [EarbudBattery] {
        let name = device.name ?? "AirPods"
        return [(EarbudBattery.Side.left, leftKey), (.right, rightKey)].compactMap { side, key in
            guard let percentage = percentage(of: device, forKey: key) else { return nil }
            return EarbudBattery(deviceName: name, side: side, percentage: percentage)
        }
    }

    private static func percentage(of device: IOBluetoothDevice, forKey key: String) -> Int? {
        guard device.responds(to: NSSelectorFromString(key)), let percentage = device.value(forKey: key) as? Int, (1...100).contains(percentage) else { return nil }
        return percentage
    }
}
