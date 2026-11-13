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
            controlsFeature: await featureIndex(of: HIDPPRequest.reprogrammableControlsFeature, at: index, on: channel)
        )
    }

    private static func featureIndex(of feature: UInt16, at index: UInt8, on channel: HIDPPChannel) async -> UInt8? {
        guard let featureIndex = await channel.send(.featureIndex(of: feature, on: index))?.parameters?.first, featureIndex != 0 else { return nil }
        return featureIndex
    }
}
