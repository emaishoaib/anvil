import MouseKit
import SwiftUI

/// The ratchet row in a Logitech mouse's group: a slider for how fast a flick of the wheel has to be before the ratchet lets go and the wheel spins freely. At the top of the slider the ratchet always stays engaged. The speed is saved only when the slider is let go, so a drag sends the mouse one change rather than one for every step.
struct DisengageRow: View {
    @Bindable private var library = MouseSettingsLibrary.shared
    @State private var draggedSpeed: Double?

    var body: some View {
        LabeledContent {
            HStack {
                Slider(value: speed, in: Self.speeds, step: 1, onEditingChanged: finishedDragging)
                Text(Self.name(of: shownSpeed))
                    .monospacedDigit()
                    .frame(width: 96, alignment: .trailing)
            }
        } label: {
            Text("Disengage")
            Text("How fast a flick frees the wheel")
        }
    }

    private static let speeds = Double(SmartShift.disengageSpeeds.lowerBound)...Double(SmartShift.disengageSpeeds.upperBound)

    private static func name(of speed: Int) -> String {
        speed >= SmartShift.disengageSpeeds.upperBound ? "Always Engage" : "\(speed)"
    }

    private var shownSpeed: Int {
        draggedSpeed.map { Int($0) } ?? library.settings.ratchetDisengageSpeed
    }

    private var speed: Binding<Double> {
        Binding(
            get: { draggedSpeed ?? Double(library.settings.ratchetDisengageSpeed) },
            set: { draggedSpeed = $0 }
        )
    }

    private func finishedDragging(isEditing: Bool) {
        guard !isEditing, let draggedSpeed else { return }
        library.settings.ratchetDisengageSpeed = Int(draggedSpeed)
        self.draggedSpeed = nil
    }
}
