import RulesKit
import SwiftUI

struct RuleEditor: View {
    let isNew: Bool
    let triggerKinds: [RuleTriggerKind]
    let save: (Rule) -> Void
    @State private var draft: RuleDraft
    @Environment(\.dismiss) private var dismiss

    init(draft: RuleDraft, isNew: Bool, triggerKinds: [RuleTriggerKind], save: @escaping (Rule) -> Void) {
        self.isNew = isNew
        self.triggerKinds = triggerKinds
        self.save = save
        _draft = State(initialValue: draft)
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("When") {
                    RuleTriggerFields(draft: $draft, kinds: triggerKinds)
                }
                Section("In") {
                    RuleAppsPicker(apps: $draft.apps)
                }
                Section("Do") {
                    RuleActionFields(draft: $draft)
                }
            }
            .formStyle(.grouped)
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isNew ? "Create Rule" : "Update Rule") {
                    if let rule = draft.rule { save(rule) }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(draft.rule == nil)
            }
            .padding([.horizontal, .bottom], 20)
        }
        .frame(width: 520)
        .navigationTitle(isNew ? "Create Rule" : "Edit Rule")
    }
}
