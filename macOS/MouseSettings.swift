import Foundation
import MouseKit

nonisolated struct MouseSettings: Codable, Equatable, Sendable {
    static let defaults = MouseSettings()

    var reversesWheel = true
    var reversesThumbWheel = true
    var durationFrames = 12
    var brakeFrame = 4
    var pointsPerTick = 90.0
    var acceleration = 0.4
    var commandScrollSpeed = CommandScrollSpeed.tenth

    var scroll: ScrollSettings {
        ScrollSettings(durationFrames: durationFrames, brakeFrame: brakeFrame, pointsPerTick: pointsPerTick, acceleration: acceleration)
    }

    init() {}

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = Self.defaults
        reversesWheel = try container.decodeIfPresent(Bool.self, forKey: .reversesWheel) ?? defaults.reversesWheel
        reversesThumbWheel = try container.decodeIfPresent(Bool.self, forKey: .reversesThumbWheel) ?? defaults.reversesThumbWheel
        durationFrames = try container.decodeIfPresent(Int.self, forKey: .durationFrames) ?? defaults.durationFrames
        brakeFrame = try container.decodeIfPresent(Int.self, forKey: .brakeFrame) ?? defaults.brakeFrame
        pointsPerTick = try container.decodeIfPresent(Double.self, forKey: .pointsPerTick) ?? defaults.pointsPerTick
        acceleration = try container.decodeIfPresent(Double.self, forKey: .acceleration) ?? defaults.acceleration
        commandScrollSpeed = try container.decodeIfPresent(CommandScrollSpeed.self, forKey: .commandScrollSpeed) ?? defaults.commandScrollSpeed
    }
}
