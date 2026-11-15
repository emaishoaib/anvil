import MouseKit

enum LogitechDiscovery {
    static func devices(on channel: HIDPPChannel) async -> [LogitechDevice] {
        if let direct = await device(at: HIDPPRequest.directDeviceIndex, on: channel) { return [direct] }
        var found: [LogitechDevice] = []
        for slot in HIDPPRequest.receiverSlots {
            if let device = await device(at: slot, on: channel) { found.append(device) }
        }
        return found
    }

    static func device(at index: UInt8, on channel: HIDPPChannel) async -> LogitechDevice? {
        guard let version = await channel.send(.protocolVersion(of: index))?.parameters, version.first ?? 0 >= 2,
              let nameFeature = await featureIndex(of: HIDPPRequest.deviceNameFeature, at: index, on: channel),
              let length = await channel.send(.nameLength(of: index, nameFeature: nameFeature))?.parameters?.first
        else { return nil }
        var parts: [[UInt8]] = []
        while parts.map(\.count).reduce(0, +) < Int(length),
              let part = await channel.send(.namePart(of: index, nameFeature: nameFeature, from: parts.map(\.count).reduce(0, +)))?.parameters {
            parts.append(part)
        }
        let kind = await channel.send(.kind(of: index, nameFeature: nameFeature))?.parameters?.first.flatMap(LogitechDeviceKind.init(rawValue:))
        return LogitechDevice(
            channel: channel.id,
            name: LogitechDevice.name(from: parts, length: Int(length)),
            kind: kind,
            deviceIndex: index,
            controlsFeature: await featureIndex(of: HIDPPRequest.reprogrammableControlsFeature, at: index, on: channel),
            wheelFeature: await featureIndex(of: HIDPPRequest.wheelFeature, at: index, on: channel),
            wirelessStatusFeature: await featureIndex(of: HIDPPRequest.wirelessStatusFeature, at: index, on: channel),
            smartShiftFeature: await smartShiftFeature(at: index, on: channel),
            batteryFeature: await featureIndex(of: HIDPPRequest.unifiedBatteryFeature, at: index, on: channel),
            dpiFeature: await featureIndex(of: HIDPPRequest.adjustableDPIFeature, at: index, on: channel)
        )
    }

    private static func smartShiftFeature(at index: UInt8, on channel: HIDPPChannel) async -> SmartShiftFeature? {
        for version in SmartShiftFeature.Version.allCases {
            if let featureIndex = await featureIndex(of: version.id, at: index, on: channel) {
                return SmartShiftFeature(index: featureIndex, version: version)
            }
        }
        return nil
    }

    private static func featureIndex(of feature: UInt16, at index: UInt8, on channel: HIDPPChannel) async -> UInt8? {
        guard let featureIndex = await channel.send(.featureIndex(of: feature, on: index))?.parameters?.first, featureIndex != 0 else { return nil }
        return featureIndex
    }
}
