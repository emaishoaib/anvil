/// What a setting's row holds on its right, and what Return does to it.
enum SettingRow {
    case toggle(isOn: Bool, set: @MainActor (Bool) -> Void)
    case choice(selected: Int, options: [String], pick: @MainActor (Int) -> Void)

    var actionTitle: String {
        switch self {
        case .toggle(let isOn, _): isOn ? "Turn Off" : "Turn On"
        case .choice: "Choose"
        }
    }
}
