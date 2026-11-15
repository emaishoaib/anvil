import AppKit
import LauncherKit
import Observation

/// Settings mode in the search bar: the settings that match the query, grouped by tool, which one is selected, and the number being adjusted, if any.
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

    private(set) var sections: [Section] = []
    private(set) var selected = 0
    private(set) var adjustment: Adjustment?
    private var shown: [Setting] = []
    @ObservationIgnored private var settings: [Setting] = []
    @ObservationIgnored private var query = ""

    var selectedSetting: Setting? {
        shown.indices.contains(selected) ? shown[selected] : nil
    }

    var isAdjusting: Bool { adjustment != nil }

    var selectedActionTitle: String? {
        guard let selectedSetting, !selectedSetting.isDisabled else { return nil }
        return adjustedValue(of: selectedSetting) == nil ? selectedSetting.row.actionTitle : "Done"
    }

    func isSelected(_ setting: Setting) -> Bool {
        selectedSetting?.id == setting.id
    }

    func adjustedValue(of setting: Setting) -> Double? {
        guard let adjustment, adjustment.settingID == setting.id else { return nil }
        return adjustment.value
    }

    func reload() {
        settings = SettingsCatalog.settings()
    }

    func filter(_ query: String) {
        finishAdjusting()
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
        case .choice:
            break
        }
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

    func finishAdjusting() {
        guard let adjustment else { return }
        self.adjustment = nil
        guard case .number(let number) = shown.first(where: { $0.id == adjustment.settingID })?.row else { return }
        if number.savesOnlyWhenDone { number.set(adjustment.value) }
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

    private func refresh() {
        let selectedID = selectedSetting?.id
        reload()
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
