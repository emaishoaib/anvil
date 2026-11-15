import AppKit
import LauncherKit
import Observation

/// Settings mode in the search bar: the settings that match the query, grouped by tool, and which one is selected.
@MainActor @Observable final class SettingsBarModel {
    struct Section: Identifiable {
        let title: String
        let settings: [Setting]

        var id: String { title }
    }

    private(set) var sections: [Section] = []
    private(set) var selected = 0
    private var shown: [Setting] = []
    @ObservationIgnored private var settings: [Setting] = []
    @ObservationIgnored private var query = ""

    var selectedSetting: Setting? {
        shown.indices.contains(selected) ? shown[selected] : nil
    }

    var selectedActionTitle: String? {
        guard let selectedSetting, !selectedSetting.isDisabled else { return nil }
        return selectedSetting.row.actionTitle
    }

    func isSelected(_ setting: Setting) -> Bool {
        selectedSetting?.id == setting.id
    }

    func reload() {
        settings = SettingsCatalog.settings()
    }

    func filter(_ query: String) {
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
        guard case .toggle(let isOn, let set) = setting.row else { return }
        set(!isOn)
        refresh(keeping: setting)
    }

    func pick(_ index: Int, for setting: Setting) {
        guard case .choice(_, _, let pick) = setting.row else { return }
        pick(index)
        refresh(keeping: setting)
    }

    private func refresh(keeping setting: Setting) {
        reload()
        show(matching: query)
        selected = shown.firstIndex { $0.id == setting.id } ?? 0
    }

    private func show(matching query: String) {
        let settingsByID = Dictionary(uniqueKeysWithValues: settings.map { ($0.id, $0) })
        sections = SettingSearch.matches(for: query, in: settings.map(\.entry)).map { group in
            Section(title: group.toolName, settings: group.entries.compactMap { settingsByID[$0.id] })
        }
        shown = sections.flatMap(\.settings)
    }
}
