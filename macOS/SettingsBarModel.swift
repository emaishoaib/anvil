import AppKit
import Carbon.HIToolbox
import LauncherKit
import Observation

/// Settings mode in the search bar: the settings that match the query, grouped by tool, which one is selected, and the number being adjusted or the shortcut being recorded, if any. Shortcut clashes with macOS are worked out against the system shortcuts read once when settings mode opens.
@MainActor @Observable final class SettingsBarModel {
    struct Section: Identifiable {
        let title: String
        let settings: [Setting]

        var id: String { title }
    }

    struct Adjustment {
        let settingID: String
        let value: Double
    }

    private static let requiredModifiers: KeyModifiers = [.control, .option, .command]

    let recording = ShortcutRecording()
    private(set) var sections: [Section] = []
    private(set) var selected = 0
    private(set) var adjustment: Adjustment?
    private var shown: [Setting] = []
    @ObservationIgnored private var settings: [Setting] = []
    @ObservationIgnored private var query = ""
    @ObservationIgnored private var systemShortcuts: Set<KeyCombo> = []

    var selectedSetting: Setting? {
        shown.indices.contains(selected) ? shown[selected] : nil
    }

    var isAdjusting: Bool { adjustment != nil }

    var selectedActionTitle: String? {
        guard let selectedSetting, !selectedSetting.isDisabled, !isRecording(selectedSetting) else { return nil }
        return adjustedValue(of: selectedSetting) == nil ? selectedSetting.row.actionTitle : "Done"
    }

    func isSelected(_ setting: Setting) -> Bool {
        selectedSetting?.id == setting.id
    }

    func isRecording(_ setting: Setting) -> Bool {
        recording.settingID == setting.id
    }

    func adjustedValue(of setting: Setting) -> Double? {
        guard let adjustment, adjustment.settingID == setting.id else { return nil }
        return adjustment.value
    }

    func reload() {
        systemShortcuts = SystemShortcuts.enabled()
        rebuild()
    }

    func filter(_ query: String) {
        finishEditing()
        self.query = query
        show(matching: query)
        selected = 0
    }

    func moveSelection(by offset: Int) {
        guard !shown.isEmpty else { return }
        selected = min(max(selected + offset, 0), shown.count - 1)
    }

    func select(_ setting: Setting) {
        selected = shown.firstIndex { $0.id == setting.id } ?? selected
    }

    func activate(_ setting: Setting) {
        guard !setting.isDisabled else { return NSSound.beep() }
        switch current(setting).row {
        case .toggle(let isOn, let set):
            set(!isOn)
            refresh()
        case .number(let number):
            adjustment = Adjustment(settingID: setting.id, value: number.value)
        case .shortcut:
            recording.start(for: setting.id) { [weak self] combo in self?.typed(combo) }
        case .choice:
            break
        }
    }

    func clearSelectedShortcut() -> Bool {
        guard let selectedSetting, case .shortcut(let combo, let canClear, let record) = selectedSetting.row else { return false }
        guard canClear, combo != nil else {
            NSSound.beep()
            return true
        }
        record(nil)
        refresh()
        return true
    }

    func pick(_ index: Int, for setting: Setting) {
        guard case .choice(_, _, let pick) = current(setting).row else { return }
        pick(index)
        refresh()
    }

    func step(by steps: Int) {
        guard let adjustment, case .number(let number) = shown.first(where: { $0.id == adjustment.settingID })?.row else { return }
        adjust(adjustment.settingID, number, to: adjustment.value + Double(steps) * number.step)
    }

    func drag(_ setting: Setting, to value: Double) {
        guard !setting.isDisabled, case .number(let number) = current(setting).row else { return }
        if adjustment?.settingID != setting.id {
            finishAdjusting()
            select(setting)
        }
        adjust(setting.id, number, to: value)
    }

    func finishEditing() {
        finishAdjusting()
        recording.stop()
    }

    func finishAdjusting() {
        guard let adjustment else { return }
        self.adjustment = nil
        guard case .number(let number) = shown.first(where: { $0.id == adjustment.settingID })?.row else { return }
        if number.savesOnlyWhenDone { number.set(adjustment.value) }
        refresh()
    }

    private func typed(_ combo: KeyCombo) {
        if combo.keyCode == kVK_Escape, combo.modifiers.isEmpty { return recording.stop() }
        guard !combo.modifiers.isDisjoint(with: Self.requiredModifiers) else { return NSSound.beep() }
        let recorded = shown.first { $0.id == recording.settingID }
        recording.stop()
        guard case .shortcut(_, _, let record) = recorded?.row else { return }
        record(combo)
        refresh()
    }

    private func adjust(_ settingID: String, _ number: SettingNumber, to value: Double) {
        let value = number.clamped(value)
        adjustment = Adjustment(settingID: settingID, value: value)
        guard !number.savesOnlyWhenDone else { return }
        number.set(value)
        refresh()
    }

    private func current(_ setting: Setting) -> Setting {
        shown.first { $0.id == setting.id } ?? setting
    }

    private func rebuild() {
        settings = SettingsCatalog.settings(systemShortcuts: systemShortcuts)
    }

    private func refresh() {
        let selectedID = selectedSetting?.id
        rebuild()
        show(matching: query)
        selected = shown.firstIndex { $0.id == selectedID } ?? 0
    }

    private func show(matching query: String) {
        let settingsByID = Dictionary(uniqueKeysWithValues: settings.map { ($0.id, $0) })
        sections = SettingSearch.matches(for: query, in: settings.map(\.entry)).map { group in
            Section(title: group.toolName, settings: group.entries.compactMap { settingsByID[$0.id] })
        }
        shown = sections.flatMap(\.settings)
    }
}
