import Carbon.HIToolbox

nonisolated struct KeyCombo: Hashable, CustomStringConvertible {
    let keyCode: Int
    let modifiers: KeyModifiers

    var description: String {
        "\(modifiers.symbols) \(keyName)"
    }

    private var keyName: String {
        switch keyCode {
        case kVK_Tab: "Tab"
        case kVK_Space: "Space"
        case kVK_Return: "Return"
        case kVK_Escape: "Esc"
        case kVK_ANSI_Grave: "`"
        default: "Key \(keyCode)"
        }
    }
}
