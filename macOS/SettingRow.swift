import RulesKit

/// What a setting's row holds on its right, and what Return does to it. An action names what Return does in the footer and returns a message to show there, if it has one, and an info row only shows a value.
enum SettingRow {
    case toggle(isOn: Bool, set: @MainActor (Bool) -> Void)
    case choice(selected: Int, options: [String], pick: @MainActor (Int) -> Void)
    case number(SettingNumber)
    case shortcut(combo: KeyCombo?, canClear: Bool, record: @MainActor (KeyCombo?) -> Void)
    case action(title: String, run: @MainActor () -> String?)
    case info(value: String?)
    case rule(Rule)

    var actionTitle: String? {
        switch self {
        case .toggle(let isOn, _): isOn ? "Turn Off" : "Turn On"
        case .choice: "Choose"
        case .number: "Adjust"
        case .shortcut: "Record Shortcut"
        case .action(let title, _): title
        case .info: nil
        case .rule: "Show Actions"
        }
    }
}
