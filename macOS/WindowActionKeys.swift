import Carbon.HIToolbox
import WindowKit

nonisolated extension WindowAction {
    var shortcut: Shortcut? {
        combo.map { Shortcut(combo: $0, action: title) }
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
        case .maximize: KeyCombo(keyCode: kVK_Return, modifiers: [.control, .option])
        case .almostMaximize: nil
        case .maximizeHeight: KeyCombo(keyCode: kVK_UpArrow, modifiers: [.control, .option, .shift])
        case .center: KeyCombo(keyCode: kVK_ANSI_C, modifiers: [.control, .option])
        case .makeSmaller: KeyCombo(keyCode: kVK_LeftArrow, modifiers: [.control, .option, .shift])
        case .makeLarger: KeyCombo(keyCode: kVK_RightArrow, modifiers: [.control, .option, .shift])
        case .moveLeft, .moveRight, .moveUp, .moveDown: nil
        }
    }

    var title: String {
        switch self {
        case .leftHalf: "Left half"
        case .rightHalf: "Right half"
        case .centerHalf: "Center half"
        case .topHalf: "Top half"
        case .bottomHalf: "Bottom half"
        case .topLeft: "Top left corner"
        case .topRight: "Top right corner"
        case .bottomLeft: "Bottom left corner"
        case .bottomRight: "Bottom right corner"
        case .firstThird: "First third"
        case .centerThird: "Center third"
        case .lastThird: "Last third"
        case .firstTwoThirds: "First two thirds"
        case .lastTwoThirds: "Last two thirds"
        case .maximize: "Maximize"
        case .almostMaximize: "Almost maximize"
        case .maximizeHeight: "Maximize height"
        case .center: "Center"
        case .makeSmaller: "Make smaller"
        case .makeLarger: "Make larger"
        case .moveLeft: "Move to the left edge"
        case .moveRight: "Move to the right edge"
        case .moveUp: "Move to the top edge"
        case .moveDown: "Move to the bottom edge"
        }
    }
}
