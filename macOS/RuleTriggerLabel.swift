import RulesKit
import SwiftUI

/// What sets off a rule, with a shortcut shown as key caps.
struct RuleTriggerLabel: View {
    let trigger: RuleTrigger

    var body: some View {
        if case .shortcut(let keystroke) = trigger {
            KeyCaps(combo: KeyCombo(keystroke))
        } else {
            Text(trigger.text)
        }
    }
}
