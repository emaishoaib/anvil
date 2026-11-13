import SwiftUI
import WindowKit

enum SnappingSettings {
    static let snapsByDraggingKey = "windows.snapsByDragging"
    static let restoresSizeWhenUnsnappedKey = "windows.restoresSizeWhenUnsnapped"
    static let maximizesOnTitleBarDoubleClickKey = "windows.maximizesOnTitleBarDoubleClick"
    static let gapKey = "windows.gap"
    static let gapRange = 0.0...50
    private static let macOSTitleBarDoubleClickKey = "AppleActionOnDoubleClick"
    private static let macOSDoesNothingOnDoubleClick = "None"

    static var maximizesOnTitleBarDoubleClick: Bool { UserDefaults.standard.bool(forKey: maximizesOnTitleBarDoubleClickKey) }
    static var macOSActsOnTitleBarDoubleClick: Bool { UserDefaults.standard.string(forKey: macOSTitleBarDoubleClickKey) != macOSDoesNothingOnDoubleClick }

    static var snapsByDragging: Bool { UserDefaults.standard.object(forKey: snapsByDraggingKey) as? Bool ?? true }
    static var restoresSizeWhenUnsnapped: Bool { UserDefaults.standard.object(forKey: restoresSizeWhenUnsnappedKey) as? Bool ?? true }
    static var gap: CGFloat { UserDefaults.standard.double(forKey: gapKey) }

    static func choiceKey(for zone: SnapZone) -> String { "windows.zone.\(zone.rawValue)" }

    static func choice(for zone: SnapZone) -> ZoneChoice {
        UserDefaults.standard.string(forKey: choiceKey(for: zone)).flatMap(ZoneChoice.init(rawValue:)) ?? zone.defaultChoice
    }
}

struct SnappingSection: View {
    @AppStorage(SnappingSettings.snapsByDraggingKey) private var snapsByDragging = true
    @AppStorage(SnappingSettings.restoresSizeWhenUnsnappedKey) private var restoresSizeWhenUnsnapped = true
    @AppStorage(SnappingSettings.maximizesOnTitleBarDoubleClickKey) private var maximizesOnTitleBarDoubleClick = false
    @AppStorage(SnappingSettings.gapKey) private var gap = 0.0

    var body: some View {
        Section("Snapping") {
            Toggle("Snap windows by dragging them to the screen edges", isOn: $snapsByDragging)
            Toggle("Restore a window's size when dragged out of a snap", isOn: $restoresSizeWhenUnsnapped)
            Toggle(isOn: $maximizesOnTitleBarDoubleClick) {
                Text("Maximize or restore a window by double-clicking its title bar")
                if maximizesOnTitleBarDoubleClick && SnappingSettings.macOSActsOnTitleBarDoubleClick {
                    Label("macOS also acts on this double-click. Set \u{201C}Double-click a window\u{2019}s title bar to\u{201D} to Do Nothing in Desktop & Dock settings.", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }
            LabeledContent("Gap between windows") {
                HStack {
                    Slider(value: $gap, in: SnappingSettings.gapRange, step: 1)
                    Text("\(Int(gap)) pt")
                        .monospacedDigit()
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        Section("Snap Zones") {
            ForEach(SnapZone.allCases, id: \.self) { zone in
                SnapZoneRow(zone: zone)
            }
        }
        .disabled(!snapsByDragging)
    }
}
