import RulesKit
import SwiftUI

struct RuleTriggerFields: View {
    @Binding var draft: RuleDraft
    let kinds: [RuleTriggerKind]

    var body: some View {
        Picker("Trigger", selection: $draft.triggerKind) {
            ForEach(kinds) { kind in
                Text(kind.title).tag(kind)
            }
        }
        .onChange(of: draft.triggerKind) {
            if !draft.actionKind.isAvailable(for: draft.triggerKind) { draft.actionKind = .sendShortcut }
        }
        switch draft.triggerKind {
        case .shortcut:
            LabeledContent("Shortcut") {
                ShortcutRecorder(combo: draft.shortcut, requiresModifier: false) { draft.shortcut = $0 }
            }
        case .mouseButton:
            MouseButtonPicker(selection: $draft.mouseButton)
        case .mouseDrag:
            MouseButtonPicker(selection: $draft.mouseButton)
            Picker("Direction", selection: $draft.dragDirection) {
                ForEach(DragDirection.allCases, id: \.self) { direction in
                    Text(direction.rawValue.capitalized).tag(direction)
                }
            }
            .pickerStyle(.segmented)
            Text("Hold the button and move the mouse this way. A click without moving still does the button's own rule.")
                .foregroundStyle(.secondary)
        case .appOpens:
            Text("Runs when one of the chosen apps opens.")
                .foregroundStyle(.secondary)
        case .appComesToFront:
            Text("Runs whenever one of the chosen apps comes to the front.")
                .foregroundStyle(.secondary)
        }
    }
}

private struct MouseButtonPicker: View {
    @Binding var selection: Int?

    var body: some View {
        Picker("Button", selection: $selection) {
            Text("Choose a Button").tag(Int?.none)
            ForEach(MouseButton.numbers, id: \.self) { number in
                Text(MouseButton.name(for: number)).tag(Int?.some(number))
            }
        }
    }
}
