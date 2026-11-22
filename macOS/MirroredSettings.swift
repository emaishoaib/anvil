import ClaudeKit
import Foundation
import LauncherKit
import WindowKit

/// Which of Anvil's own preferences go in which section of the settings file, each under a plain name of its own in that section: the General settings with the tool switches and the currency table's currencies, the AI settings, and the Windows settings with every window shortcut and snap zone. Each section names the file it used to be, so that file can be brought in. Every entry carries its default, saved the way the preference itself is, and the defaults are registered so a setting never changed still has a value to write.
enum MirroredSettings {
    struct Section {
        let name: String
        let oldFile: String
        let entries: [Entry]
    }

    struct Entry {
        let name: String
        let key: String
        let defaultValue: Any
    }

    static let sections = [general, ai, windows]

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: Dictionary(uniqueKeysWithValues: sections.flatMap(\.entries).map { ($0.key, $0.defaultValue) }))
    }

    private static var general: Section {
        Section(name: "general", oldFile: "general.json", entries: [
            Entry(name: "searchBarShortcut", key: LauncherKeys.savedKey, defaultValue: LauncherKeys.defaultCombo.savedText),
            Entry(name: "searchMemory", key: SearchMemory.savedKey, defaultValue: SearchMemory.defaultChoice.rawValue),
            Entry(name: "currencies", key: ChosenCurrencies.savedKey, defaultValue: CurrencyChoices.startingCodes()),
            Entry(name: "workingAnimation", key: WorkingAnimation.savedKey, defaultValue: WorkingAnimation.defaultChoice.rawValue),
        ] + Tool.allCases.filter(\.canBeTurnedOff).map { Entry(name: "use.\($0.rawValue)", key: $0.isOnKey, defaultValue: $0.isOnByDefault) })
    }

    private static var ai: Section {
        Section(name: "ai", oldFile: "ai.json", entries: [
            Entry(name: "listenShortcut", key: AIKeys.savedKey, defaultValue: AIKeys.defaultCombo.savedText),
            Entry(name: "afterSending", key: AfterSending.savedKey, defaultValue: AfterSending.defaultChoice.rawValue),
            Entry(name: "unnamedSpeech", key: UnnamedSpeech.savedKey, defaultValue: UnnamedSpeech.defaultSession.rawValue),
        ] + SpokenPhrase.allCases.map { Entry(name: "\($0).phrase", key: $0.savedKey, defaultValue: $0.defaultPhrase) })
    }

    private static var windows: Section {
        Section(name: "windows", oldFile: "windows.json", entries: [
            Entry(name: "snapsByDragging", key: SnappingSettings.snapsByDraggingKey, defaultValue: SnappingSettings.snapsByDraggingByDefault),
            Entry(name: "restoresSizeWhenUnsnapped", key: SnappingSettings.restoresSizeWhenUnsnappedKey, defaultValue: SnappingSettings.restoresSizeWhenUnsnappedByDefault),
            Entry(name: "maximizesOnTitleBarDoubleClick", key: SnappingSettings.maximizesOnTitleBarDoubleClickKey, defaultValue: SnappingSettings.maximizesOnTitleBarDoubleClickByDefault),
            Entry(name: "gap", key: SnappingSettings.gapKey, defaultValue: SnappingSettings.defaultGap),
        ] + SnapZone.allCases.map { Entry(name: "zone.\($0.rawValue)", key: SnappingSettings.choiceKey(for: $0), defaultValue: $0.defaultChoice.rawValue) }
            + WindowCommand.allCases.map { Entry(name: String($0.savedKey.dropFirst("windows.".count)), key: $0.savedKey, defaultValue: WindowShortcuts.savedText(for: $0.defaultCombo)) })
    }
}
