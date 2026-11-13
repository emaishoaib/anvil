import RulesKit
import SwiftUI

struct RulesSection: View {
    private let library = RuleLibrary.shared
    @State private var editing: RuleDraft?
    @State private var deleting: Rule?

    var body: some View {
        Section("Rules") {
            if library.all.isEmpty {
                Text("No rules yet").foregroundStyle(.secondary)
            }
            ForEach(library.all) { rule in
                RuleRow(rule: rule, edit: { editing = RuleDraft(rule) }, delete: { deleting = rule })
            }
            Button("Add Rule…") { editing = RuleDraft() }
        }
        .sheet(item: $editing) { draft in
            RuleEditor(draft: draft, isNew: !library.contains(draft.id), save: library.save)
        }
        .confirmationDialog("Delete this rule?", isPresented: isConfirmingDelete, presenting: deleting) { rule in
            Button("Delete Rule", role: .destructive) { library.delete(rule) }
        } message: { _ in
            Text("This can't be undone.")
        }
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding(
            get: { deleting != nil },
            set: { if !$0 { deleting = nil } }
        )
    }
}
