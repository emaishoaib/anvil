import MouseKit

/// Sets each Logitech mouse to the DPI chosen in the mouse settings while the mouse tool is on, moved to the nearest DPI the mouse accepts. The DPI the mouse had before is kept, and set again when the tool or the setting is turned off. Each call gives back the mouse's DPI as it now stands, so the settings page can show it.
final class MouseDPI {
    static let shared = MouseDPI()

    private var originalDPIs: [String: Int] = [:]

    func apply(to device: LogitechDevice, on channel: HIDPPChannel) async -> SensorDPI? {
        guard let dpiFeature = device.dpiFeature,
              let list = await channel.send(.dpiList(of: device.deviceIndex, dpiFeature: dpiFeature))?.parameters,
              let current = await channel.send(.dpi(of: device.deviceIndex, dpiFeature: dpiFeature))?.parameters,
              let dpi = SensorDPI(current: current, list: list)
        else { return nil }
        let wanted: Int?
        if Tool.mouse.isOn, let chosen = MouseSettingsLibrary.current.dpi {
            originalDPIs[device.id] = originalDPIs[device.id] ?? dpi.current
            wanted = dpi.nearestChoice(to: chosen)
        } else {
            wanted = originalDPIs.removeValue(forKey: device.id)
        }
        guard let wanted, wanted != dpi.current,
              await channel.send(.setDPI(wanted, of: device.deviceIndex, dpiFeature: dpiFeature))?.parameters != nil
        else { return dpi }
        return SensorDPI(current: wanted, choices: dpi.choices)
    }
}
