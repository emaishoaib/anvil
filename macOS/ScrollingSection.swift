import MouseKit
import SwiftUI

nonisolated enum ScrollingSettings {
    static let reversesWheelKey = "mouse.reversesWheel"
    static let reversesThumbWheelKey = "mouse.reversesThumbWheel"
    static let durationFramesKey = "mouse.scrollDurationFrames"
    static let brakeFrameKey = "mouse.scrollBrakeFrame"
    static let pointsPerTickKey = "mouse.scrollPointsPerTick"
    static let accelerationKey = "mouse.scrollAcceleration"
    static let commandScrollSpeedKey = "mouse.commandScrollSpeed"
    static let durationFramesRange = 2.0...60
    static let pointsPerTickRange = 10.0...300
    static let accelerationRange = 0.0...1
    static let defaults = ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 0.4)

    static var reversesWheel: Bool { UserDefaults.standard.object(forKey: reversesWheelKey) as? Bool ?? true }
    static var reversesThumbWheel: Bool { UserDefaults.standard.object(forKey: reversesThumbWheelKey) as? Bool ?? true }

    static var commandScrollSpeed: CommandScrollSpeed {
        UserDefaults.standard.string(forKey: commandScrollSpeedKey).flatMap(CommandScrollSpeed.init(rawValue:)) ?? .tenth
    }

    static var current: ScrollSettings {
        ScrollSettings(
            durationFrames: Int(value(for: durationFramesKey) ?? Double(defaults.durationFrames)),
            brakeFrame: Int(value(for: brakeFrameKey) ?? Double(defaults.brakeFrame)),
            pointsPerTick: value(for: pointsPerTickKey) ?? defaults.pointsPerTick,
            acceleration: value(for: accelerationKey) ?? defaults.acceleration
        )
    }

    static func milliseconds(frames: Double) -> Int {
        Int((frames * 1000 / ScrollSettings.framesPerSecond).rounded())
    }

    private static func value(for key: String) -> Double? {
        UserDefaults.standard.object(forKey: key) as? Double
    }
}

struct ScrollingSection: View {
    @AppStorage(ScrollingSettings.reversesWheelKey) private var reversesWheel = true
    @AppStorage(ScrollingSettings.reversesThumbWheelKey) private var reversesThumbWheel = true
    @AppStorage(ScrollingSettings.durationFramesKey) private var durationFrames = Double(ScrollingSettings.defaults.durationFrames)
    @AppStorage(ScrollingSettings.brakeFrameKey) private var brakeFrame = Double(ScrollingSettings.defaults.brakeFrame)
    @AppStorage(ScrollingSettings.pointsPerTickKey) private var pointsPerTick = ScrollingSettings.defaults.pointsPerTick
    @AppStorage(ScrollingSettings.accelerationKey) private var acceleration = ScrollingSettings.defaults.acceleration
    @AppStorage(ScrollingSettings.commandScrollSpeedKey) private var commandScrollSpeed = CommandScrollSpeed.tenth

    var body: some View {
        Section("Scrolling") {
            Toggle("Reverse the wheel's direction", isOn: $reversesWheel)
            Toggle("Reverse the thumb wheel's direction", isOn: $reversesThumbWheel)
            SliderRow(title: "Duration of each wheel click", value: $durationFrames, range: ScrollingSettings.durationFramesRange, step: 1) {
                "\(ScrollingSettings.milliseconds(frames: $0)) ms"
            }
            SliderRow(title: "Start slowing down after", value: $brakeFrame, range: 1...durationFrames, step: 1) {
                "\(ScrollingSettings.milliseconds(frames: $0)) ms"
            }
            SliderRow(title: "Distance of each wheel click", value: $pointsPerTick, range: ScrollingSettings.pointsPerTickRange, step: 5) {
                "\(Int($0)) pt"
            }
            SliderRow(title: "Acceleration", value: $acceleration, range: ScrollingSettings.accelerationRange, step: 0.05) {
                "\(Int(($0 * 100).rounded()))%"
            }
        }
        .onChange(of: durationFrames) { brakeFrame = min(brakeFrame, durationFrames) }
        Section("While Holding a Key") {
            LabeledContent("Shift", value: "Scrolls sideways")
            LabeledContent("Control", value: "Zooms in and out")
            Picker("Command", selection: $commandScrollSpeed) {
                ForEach(CommandScrollSpeed.allCases) { speed in
                    Text("\(speed.name) the speed").tag(speed)
                }
            }
        }
    }
}

private struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let label: (Double) -> String

    var body: some View {
        LabeledContent(title) {
            HStack {
                Slider(value: $value, in: range, step: step)
                Text(label(value))
                    .monospacedDigit()
                    .frame(width: 56, alignment: .trailing)
            }
        }
    }
}
