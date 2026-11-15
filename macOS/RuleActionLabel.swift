import RulesKit
import SwiftUI

/// What a rule does, with a shortcut it sends shown as key caps.
struct RuleActionLabel: View {
    let action: RuleAction

    var body: some View {
        if case .sendShortcut(let keystroke) = action {
            HStack(spacing: 6) {
                Text("Send")
                KeyCaps(combo: KeyCombo(keystroke))
            }
        } else {
            Text(action.text)
        }
    }
}
