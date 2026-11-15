import MouseKit
import SwiftUI

/// The DPI rows in a Logitech mouse's group: a switch to let Anvil set the DPI, and the DPI itself, with a slider over every DPI the mouse accepts while the switch is on. The chosen DPI is saved only when the slider is let go, so a drag sends the mouse one change rather than one for every step.
struct DPIRow: View {
    let dpi: SensorDPI
    @Bindable private var library = MouseSettingsLibrary.shared
    @State private var draggedIndex: Double?

    var body: some View {
        Toggle("Set the DPI", isOn: isSet)
        LabeledContent {
            HStack {
                if library.settings.dpi != nil, dpi.choices.count > 1 {
                    Slider(value: index, in: 0...Double(dpi.choices.count - 1), step: 1, onEditingChanged: finishedDragging)
                }
                Text(shownDPI, format: .number)
                    .monospacedDigit()
                    .frame(width: 56, alignment: .trailing)
            }
        } label: {
            Text("DPI")
            Text("Accepts \(dpi.lowest) to \(dpi.highest)")
        }
    }

    private var chosenDPI: Int {
        library.settings.dpi.map(dpi.nearestChoice) ?? dpi.current
    }

    private var shownDPI: Int {
        draggedIndex.map { dpi.choices[Int($0)] } ?? chosenDPI
    }

    private var isSet: Binding<Bool> {
        Binding(
            get: { library.settings.dpi != nil },
            set: { library.settings.dpi = $0 ? dpi.current : nil }
        )
    }

    private var index: Binding<Double> {
        Binding(
            get: { draggedIndex ?? Double(dpi.nearestIndex(to: chosenDPI)) },
            set: { draggedIndex = $0 }
        )
    }

    private func finishedDragging(isEditing: Bool) {
        guard !isEditing, let draggedIndex else { return }
        library.settings.dpi = dpi.choices[Int(draggedIndex)]
        self.draggedIndex = nil
    }
}
