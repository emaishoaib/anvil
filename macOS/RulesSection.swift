import RulesKit
import SwiftUI

struct RulesSection: View {
    let group: RuleGroup
    private let library = RuleLibrary.shared
    @State private var editing: RuleDraft?
    @State private var deleting: Rule?

    var body: some View {
        Section(group.title) {
            if let problem = library.loadProblem {
                Label(problem, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            } else if rules.isEmpty {
                Text(group.emptyText).foregroundStyle(.secondary)
            }
            Group {
                ForEach(rules) { rule in
                    RuleRow(rule: rule, edit: { editing = RuleDraft(rule) }, delete: { deleting = rule })
                }
                Button(group.addTitle) { editing = group.newDraft }
            }
            .disabled(library.loadProblem != nil)
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

    private var rules: [Rule] {
        library.all.filter(group.contains)
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding(
            get: { deleting != nil },
            set: { if !$0 { deleting = nil } }
        )
    }
}
