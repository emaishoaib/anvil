import SwiftUI

struct RuleActionFields: View {
    @Binding var draft: RuleDraft

    var body: some View {
        Picker("Action", selection: $draft.actionKind) {
            ForEach(RuleActionKind.allCases.filter { $0.isAvailable(for: draft.triggerKind) }) { kind in
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
        case .playSound:
            Picker("Sound", selection: $draft.sound) {
                Text("Choose a Sound").tag(String?.none)
                ForEach(SystemSounds.names, id: \.self) { name in
                    Text(name).tag(String?.some(name))
                }
            }
            .onChange(of: draft.sound) {
                if let sound = draft.sound { SystemSounds.play(sound) }
            }
        case .quitApp:
            Text("Quits the app that set off the rule.")
                .foregroundStyle(.secondary)
        case .resizeWindow:
            TextField("Width", value: $draft.windowWidth, format: .number, prompt: Text("1050"))
            TextField("Height", value: $draft.windowHeight, format: .number, prompt: Text("650"))
        }
    }
}
