import MouseKit
import os

/// Keeps the MX Master wheel in ratchet mode, disengaging at the speed chosen in the mouse settings, while the mouse tool is on. At the top speed the ratchet never disengages. Otherwise the ratchet disengages on a fast flick, at the mouse's own default speed. Each time, it logs what the mouse reported, what it wrote and what the mouse reports afterwards.
enum WheelRatchet {
    private static let recheckPauses: [Duration] = [.zero, .seconds(3), .seconds(10)]

    /// Reads the ratchet again a few times after a device is set up, and sets it again whenever the mouse has gone back to its own default, as the MX Master 3S does some time after it connects.
    static func keepApplied(to device: LogitechDevice, on channel: HIDPPChannel) async {
        var waitedSeconds = 0
        for pause in recheckPauses {
            try? await Task.sleep(for: pause)
            waitedSeconds += Int(pause.components.seconds)
            Logger.logitech.notice("Checking the ratchet on \(device.name, privacy: .public) again, \(waitedSeconds) s after setting it up")
            await apply(to: device, on: channel)
        }
    }

    static func apply(to device: LogitechDevice, on channel: HIDPPChannel) async {
        guard device.kind == .mouse, let feature = device.smartShiftFeature,
              let parameters = await channel.send(.smartShift(of: device.deviceIndex, feature: feature))?.parameters
        else { return }
        let wanted: SmartShift? = if Tool.mouse.isOn {
            .ratchet(disengagingAt: MouseSettingsLibrary.current.ratchetDisengageSpeed)
        } else {
            .ratchetDisengagingAtDefaultSpeed(from: parameters)
        }
        let version = String(describing: feature.version)
        guard let wanted, wanted != SmartShift(parameters: parameters) else {
            Logger.logitech.notice("Ratchet on \(device.name, privacy: .public) (\(version, privacy: .public)) reports \(Array(parameters.prefix(3)).logHex, privacy: .public), left as it is")
            return
        }
        _ = await channel.send(.setSmartShift(wanted, of: device.deviceIndex, feature: feature))
        let after = await channel.send(.smartShift(of: device.deviceIndex, feature: feature))?.parameters
        let written = [wanted.mode.rawValue, wanted.disengageSpeed].logHex
        let reportedAfter = after.map { Array($0.prefix(3)).logHex } ?? "nothing"
        Logger.logitech.notice("Ratchet on \(device.name, privacy: .public) (\(version, privacy: .public)) reported \(Array(parameters.prefix(3)).logHex, privacy: .public), wrote \(written, privacy: .public), now reports \(reportedAfter, privacy: .public)")
    }
}
