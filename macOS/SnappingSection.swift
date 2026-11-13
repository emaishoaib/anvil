import SwiftUI

enum SnappingSettings {
    static let gapKey = "windows.gap"
    static let gapRange = 0.0...50

    static var gap: CGFloat { UserDefaults.standard.double(forKey: gapKey) }
}

struct SnappingSection: View {
    @AppStorage(SnappingSettings.gapKey) private var gap = 0.0

    var body: some View {
        Section("Snapping") {
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
