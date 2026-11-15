import SwiftUI

/// The thumb wheel rows in a Logitech mouse's group: what turning it does, how fast that goes, as a gain on Anvil's base speed, and whether its direction is inverted.
struct ThumbWheelRows: View {
    private static let speedGains = 0.25...4.0
    private static let speedGainStep = 0.25

    @Bindable private var library = MouseSettingsLibrary.shared

    var body: some View {
        Picker("Thumb wheel", selection: $library.settings.thumbWheelEffect) {
            ForEach(WheelEffect.allCases, id: \.self) { effect in
                Text(effect.name).tag(effect)
            }
        }
        LabeledContent("Thumb wheel speed") {
            HStack {
                Slider(value: $library.settings.thumbWheelSpeedGain, in: Self.speedGains, step: Self.speedGainStep)
                Text(library.settings.thumbWheelSpeedGain, format: .number.precision(.fractionLength(2)))
                    .monospacedDigit()
                    .frame(width: 56, alignment: .trailing)
            }
        }
        Toggle("Invert the thumb wheel", isOn: $library.settings.reversesThumbWheel)
    }
}
