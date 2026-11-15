import Foundation
import WindowKit

enum SnappingSettings {
    static let snapsByDraggingKey = "windows.snapsByDragging"
    static let restoresSizeWhenUnsnappedKey = "windows.restoresSizeWhenUnsnapped"
    static let maximizesOnTitleBarDoubleClickKey = "windows.maximizesOnTitleBarDoubleClick"
    static let gapKey = "windows.gap"
    static let gapRange = 0.0...50
    static let macOSDoubleClickWarning = "macOS also acts on this double-click. Set \u{201C}Double-click a window\u{2019}s title bar to\u{201D} to Do Nothing in Desktop & Dock settings."
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
