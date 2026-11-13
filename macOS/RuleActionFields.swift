import SwiftUI

struct RuleActionFields: View {
    @Binding var draft: RuleDraft

    var body: some View {
        Picker("Action", selection: $draft.actionKind) {
            ForEach(RuleActionKind.allCases) { kind in
                Text(kind.title).tag(kind)
            }
        }
        switch draft.actionKind {
        case .sendShortcut:
            LabeledContent("Shortcut") {
                ShortcutRecorder(combo: draft.shortcutToSend, requiresModifier: false) { draft.shortcutToSend = $0 }
            }
        case .chooseMenuItem:
            TextField("Menu Item", text: $draft.menuItem, prompt: Text("View > Terminal"))
        }
    }
}
