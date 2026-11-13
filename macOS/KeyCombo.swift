import Carbon.HIToolbox

nonisolated struct KeyCombo: Hashable, CustomStringConvertible {
    let keyCode: Int
    let modifiers: KeyModifiers

    var description: String {
        "\(modifiers.symbols) \(keyName)"
    }

    var keyName: String {
        switch keyCode {
        case kVK_Tab: "Tab"
        case kVK_Space: "Space"
        case kVK_Return: "Return"
        case kVK_Escape: "Esc"
        case kVK_ANSI_Grave: "`"
        case kVK_ANSI_Period: "."
        case kVK_ANSI_C: "C"
        case kVK_ANSI_D: "D"
        case kVK_ANSI_E: "E"
        case kVK_ANSI_K: "K"
        case kVK_ANSI_O: "O"
        case kVK_ANSI_X: "X"
        default: "Key \(keyCode)"
        }
    }
}
