import Carbon.HIToolbox
import WindowKit

nonisolated extension WindowAction {
    var shortcut: Shortcut? {
        combo.map { Shortcut(combo: $0, action: "Snap to the \(place)") }
    }

    private var combo: KeyCombo? {
        switch self {
        case .leftHalf: KeyCombo(keyCode: kVK_LeftArrow, modifiers: [.control, .option])
        case .rightHalf: KeyCombo(keyCode: kVK_RightArrow, modifiers: [.control, .option])
        case .centerHalf: nil
        case .topHalf: KeyCombo(keyCode: kVK_UpArrow, modifiers: [.option, .command])
        case .bottomHalf: KeyCombo(keyCode: kVK_DownArrow, modifiers: [.option, .command])
        case .topLeft: KeyCombo(keyCode: kVK_LeftArrow, modifiers: [.control, .command])
        case .topRight: KeyCombo(keyCode: kVK_RightArrow, modifiers: [.control, .command])
        case .bottomLeft: KeyCombo(keyCode: kVK_LeftArrow, modifiers: [.control, .shift, .command])
        case .bottomRight: KeyCombo(keyCode: kVK_RightArrow, modifiers: [.control, .shift, .command])
        case .firstThird: KeyCombo(keyCode: kVK_ANSI_D, modifiers: [.control, .option])
        case .centerThird: KeyCombo(keyCode: kVK_ANSI_F, modifiers: [.control, .option])
        case .lastThird: KeyCombo(keyCode: kVK_ANSI_G, modifiers: [.control, .option])
        case .firstTwoThirds: KeyCombo(keyCode: kVK_ANSI_E, modifiers: [.control, .option])
        case .lastTwoThirds: KeyCombo(keyCode: kVK_ANSI_T, modifiers: [.control, .option])
        }
    }

    private var place: String {
        switch self {
        case .leftHalf: "left half"
        case .rightHalf: "right half"
        case .centerHalf: "center half"
        case .topHalf: "top half"
        case .bottomHalf: "bottom half"
        case .topLeft: "top left corner"
        case .topRight: "top right corner"
        case .bottomLeft: "bottom left corner"
        case .bottomRight: "bottom right corner"
        case .firstThird: "first third"
        case .centerThird: "center third"
        case .lastThird: "last third"
        case .firstTwoThirds: "first two thirds"
        case .lastTwoThirds: "last two thirds"
        }
    }
}
