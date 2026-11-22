import Foundation
import WindowKit

/// Which of Anvil's own preferences go in which section of the settings file, each under a plain name of its own in that section: the General settings with the tool switches and the currency table's currencies, the AI settings, and the Windows settings with every window shortcut and snap zone. Each section names the file it used to be, so that file can be brought in.
enum MirroredSettings {
    struct Section {
        let name: String
        let oldFile: String
        let entries: [(name: String, key: String)]
    }

    static let sections = [general, ai, windows]

    private static var general: Section {
        Section(name: "general", oldFile: "general.json", entries: [
            ("searchBarShortcut", LauncherKeys.savedKey),
            ("searchMemory", SearchMemory.savedKey),
            ("currencies", ChosenCurrencies.savedKey),
            ("workingAnimation", WorkingAnimation.savedKey),
        ] + Tool.allCases.filter(\.canBeTurnedOff).map { ("use.\($0.rawValue)", $0.isOnKey) })
    }

    private static var ai: Section {
        Section(name: "ai", oldFile: "ai.json", entries: [
            ("listenShortcut", AIKeys.savedKey),
            ("afterSending", AfterSending.savedKey),
            ("unnamedSpeech", UnnamedSpeech.savedKey),
        ] + SpokenPhrase.allCases.map { ("\($0).phrase", $0.savedKey) })
    }

    private static var windows: Section {
        Section(name: "windows", oldFile: "windows.json", entries: [
            ("snapsByDragging", SnappingSettings.snapsByDraggingKey),
            ("restoresSizeWhenUnsnapped", SnappingSettings.restoresSizeWhenUnsnappedKey),
            ("maximizesOnTitleBarDoubleClick", SnappingSettings.maximizesOnTitleBarDoubleClickKey),
            ("gap", SnappingSettings.gapKey),
        ] + SnapZone.allCases.map { ("zone.\($0.rawValue)", SnappingSettings.choiceKey(for: $0)) }
            + WindowCommand.allCases.map { (String($0.savedKey.dropFirst("windows.".count)), $0.savedKey) })
    }
}
