import Carbon.HIToolbox
import WindowKit

nonisolated extension WindowAction {
    var shortcut: Shortcut? {
        combo.map { Shortcut(combo: $0, action: name) }
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

    private var name: String {
        switch self {
        case .leftHalf: "Snap to the left half"
        case .rightHalf: "Snap to the right half"
        case .centerHalf: "Snap to the center half"
        case .topHalf: "Snap to the top half"
        case .bottomHalf: "Snap to the bottom half"
        case .topLeft: "Snap to the top left corner"
        case .topRight: "Snap to the top right corner"
        case .bottomLeft: "Snap to the bottom left corner"
        case .bottomRight: "Snap to the bottom right corner"
        case .firstThird: "Snap to the first third"
        case .centerThird: "Snap to the center third"
        case .lastThird: "Snap to the last third"
        case .firstTwoThirds: "Snap to the first two thirds"
        case .lastTwoThirds: "Snap to the last two thirds"
        case .maximize: "Maximize"
        case .almostMaximize: "Almost maximize"
        case .maximizeHeight: "Maximize the height"
        case .center: "Center on the screen"
        case .makeSmaller: "Make smaller"
        case .makeLarger: "Make larger"
        case .moveLeft: "Move to the left edge"
        case .moveRight: "Move to the right edge"
        case .moveUp: "Move to the top edge"
        case .moveDown: "Move to the bottom edge"
        }
    }
}
