import MouseKit
import SwiftUI

nonisolated enum ScrollingSettings {
    static let durationFramesRange = 2.0...60
    static let pointsPerTickRange = 10.0...300
    static let accelerationRange = 0.0...1

    static func milliseconds(frames: Double) -> Int {
        Int((frames * 1000 / ScrollSettings.framesPerSecond).rounded())
    }
}

struct ScrollingSection: View {
    @Bindable private var library = MouseSettingsLibrary.shared

    var body: some View {
        Section("Scrolling") {
            if let problem = library.loadProblem {
                Label(problem, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
            Toggle("Reverse the wheel's direction", isOn: $library.settings.reversesWheel)
            Toggle("Reverse the thumb wheel's direction", isOn: $library.settings.reversesThumbWheel)
            Toggle(isOn: $library.settings.ratchetAlwaysEngaged) {
                Text("Ratchet mode")
                Text("Always Engage")
            }
            SliderRow(title: "Duration of each wheel click", value: durationFrames, range: ScrollingSettings.durationFramesRange, step: 1) {
                "\(ScrollingSettings.milliseconds(frames: $0)) ms"
            }
            SliderRow(title: "Start slowing down after", value: brakeFrame, range: 1...Double(library.settings.durationFrames), step: 1) {
                "\(ScrollingSettings.milliseconds(frames: $0)) ms"
            }
            SliderRow(title: "Distance of each wheel click", value: $library.settings.pointsPerTick, range: ScrollingSettings.pointsPerTickRange, step: 5) {
                "\(Int($0)) pt"
            }
            SliderRow(title: "Acceleration", value: $library.settings.acceleration, range: ScrollingSettings.accelerationRange, step: 0.05) {
                "\(Int(($0 * 100).rounded()))%"
            }
        }
        Section("While Holding a Key") {
            LabeledContent("Shift", value: "Scrolls sideways")
            LabeledContent("Control", value: "Zooms in and out")
            Picker("Command", selection: $library.settings.commandScrollSpeed) {
                ForEach(CommandScrollSpeed.allCases) { speed in
                    Text("\(speed.name) the speed").tag(speed)
                }
            }
        }
    }

    private var durationFrames: Binding<Double> {
        Binding(
            get: { Double(library.settings.durationFrames) },
            set: { frames in
                library.settings.durationFrames = Int(frames)
                library.settings.brakeFrame = min(library.settings.brakeFrame, Int(frames))
            }
        )
    }

    private var brakeFrame: Binding<Double> {
        Binding(
            get: { Double(library.settings.brakeFrame) },
            set: { library.settings.brakeFrame = Int($0) }
        )
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
