import SwiftUI

enum SnappingSettings {
    static let snapsByDraggingKey = "windows.snapsByDragging"
    static let gapKey = "windows.gap"
    static let gapRange = 0.0...50

    static var snapsByDragging: Bool { UserDefaults.standard.object(forKey: snapsByDraggingKey) as? Bool ?? true }
    static var gap: CGFloat { UserDefaults.standard.double(forKey: gapKey) }
}

struct SnappingSection: View {
    @AppStorage(SnappingSettings.snapsByDraggingKey) private var snapsByDragging = true
    @AppStorage(SnappingSettings.gapKey) private var gap = 0.0

    var body: some View {
        Section("Snapping") {
            Toggle("Snap windows by dragging them to the screen edges", isOn: $snapsByDragging)
            LabeledContent("Gap between windows") {
                HStack {
                    Slider(value: $gap, in: SnappingSettings.gapRange, step: 1)
                    Text("\(Int(gap)) pt")
                        .monospacedDigit()
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
    }
}
