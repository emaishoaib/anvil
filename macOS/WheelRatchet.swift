import Foundation
import MouseKit
import os

/// Keeps the MX Master wheel in ratchet mode, disengaging at the speed chosen in the mouse settings, while the mouse tool is on. At the top speed the ratchet never disengages. Otherwise the ratchet disengages on a fast flick, at the mouse's own default speed. Each time, it logs what the mouse reported, what it wrote and what the mouse reports afterwards.
enum WheelRatchet {
    private static let quickRecheckPause = Duration.milliseconds(500)
    private static let quickRecheckCount = 10
    private static let finalRecheckPause = Duration.seconds(8)
    private static let recheckPauses: [Duration] = [.zero] + Array(repeating: quickRecheckPause, count: quickRecheckCount) + [finalRecheckPause]

    /// Reads the ratchet again after a device is set up, every half second for the first five seconds and once more at thirteen, and sets it again whenever the mouse has gone back to its own default. The MX Master 3S does that within a few seconds of connecting, so the quick checks keep the free spin it causes to half a second at most.
    static func keepApplied(to device: LogitechDevice, on channel: HIDPPChannel) async {
        var waited = Duration.zero
        for pause in recheckPauses {
            try? await Task.sleep(for: pause)
            waited += pause
            let seconds = String(format: "%.1f", waited / .seconds(1))
            Logger.logitech.info("Checking the ratchet on \(device.name, privacy: .public) again, \(seconds, privacy: .public) s after setting it up")
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
            Logger.logitech.info("Ratchet on \(device.name, privacy: .public) (\(version, privacy: .public)) reports \(Array(parameters.prefix(3)).logHex, privacy: .public), left as it is")
            return
        }
        _ = await channel.send(.setSmartShift(wanted, of: device.deviceIndex, feature: feature))
        let after = await channel.send(.smartShift(of: device.deviceIndex, feature: feature))?.parameters
        let written = [wanted.mode.rawValue, wanted.disengageSpeed].logHex
        let reportedAfter = after.map { Array($0.prefix(3)).logHex } ?? "nothing"
        Logger.logitech.notice("Ratchet on \(device.name, privacy: .public) (\(version, privacy: .public)) reported \(Array(parameters.prefix(3)).logHex, privacy: .public), wrote \(written, privacy: .public), now reports \(reportedAfter, privacy: .public)")
    }
}
