import Foundation
import WindowKit

/// Which of Anvil's own preferences go in which settings file, each under a plain name of its own in that file: the General settings with the tool switches, the AI settings, and the Windows settings with every window shortcut and snap zone.
enum MirroredSettings {
    struct File {
        let name: String
        let entries: [(name: String, key: String)]
    }

    static let files = [general, ai, windows]

    private static var general: File {
        File(name: "general.json", entries: [
            ("searchBarShortcut", LauncherKeys.savedKey),
            ("searchMemory", SearchMemory.savedKey),
            ("workingAnimation", WorkingAnimation.savedKey),
        ] + Tool.allCases.filter(\.canBeTurnedOff).map { ("use.\($0.rawValue)", $0.isOnKey) })
    }

    private static var ai: File {
        File(name: "ai.json", entries: [
            ("listenShortcut", AIKeys.savedKey),
            ("afterSending", AfterSending.savedKey),
            ("unnamedSpeech", UnnamedSpeech.savedKey),
        ] + SpokenPhrase.allCases.map { ("\($0).phrase", $0.savedKey) })
    }

    private static var windows: File {
        File(name: "windows.json", entries: [
            ("snapsByDragging", SnappingSettings.snapsByDraggingKey),
            ("restoresSizeWhenUnsnapped", SnappingSettings.restoresSizeWhenUnsnappedKey),
            ("maximizesOnTitleBarDoubleClick", SnappingSettings.maximizesOnTitleBarDoubleClickKey),
            ("gap", SnappingSettings.gapKey),
        ] + SnapZone.allCases.map { ("zone.\($0.rawValue)", SnappingSettings.choiceKey(for: $0)) }
            + WindowCommand.allCases.map { (String($0.savedKey.dropFirst("windows.".count)), $0.savedKey) })
    }
}
