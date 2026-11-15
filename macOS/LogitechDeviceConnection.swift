import MouseKit

extension LogitechDevice {
    /// What kind of device it is and how it is connected, such as "Mouse, through a receiver".
    var connection: String {
        let kind = kind?.name ?? "Device"
        return isOnAReceiver ? "\(kind), through a receiver" : "\(kind), connected directly"
    }
}
