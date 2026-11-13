import SwiftUI

struct RuleTriggerFields: View {
    @Binding var draft: RuleDraft

    var body: some View {
        Picker("Trigger", selection: $draft.triggerKind) {
            ForEach(RuleTriggerKind.allCases) { kind in
                Text(kind.title).tag(kind)
            }
        }
        switch draft.triggerKind {
        case .shortcut:
            LabeledContent("Shortcut") {
                ShortcutRecorder(combo: draft.shortcut, requiresModifier: false) { draft.shortcut = $0 }
            }
        case .mouseButton:
            Picker("Button", selection: $draft.mouseButton) {
                Text("Choose a Button").tag(Int?.none)
                ForEach(MouseButton.numbers, id: \.self) { number in
                    Text(MouseButton.name(for: number)).tag(Int?.some(number))
                }
            }
        }
    }
}
