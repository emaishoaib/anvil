import LauncherKit
import SwiftUI

struct QuickLinkEditor: View {
    let isNew: Bool
    let save: (QuickLink) -> Void
    @State private var draft: QuickLink
    @Environment(\.dismiss) private var dismiss

    init(link: QuickLink, isNew: Bool, save: @escaping (QuickLink) -> Void) {
        self.isNew = isNew
        self.save = save
        _draft = State(initialValue: link)
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("Name", text: $draft.name, prompt: Text("Quick link name"))
                    LinkField(link: $draft.link)
                } footer: {
                    Text(QuickLink.placeholderHint)
                        .foregroundStyle(.secondary)
                }
                Section {
                    OpenWithPicker(link: draft, selection: $draft.openWith)
                }
            }
            .formStyle(.grouped)
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isNew ? "Create Quick Link" : "Update Quick Link") {
                    save(draft)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!draft.isComplete)
            }
            .padding([.horizontal, .bottom], 20)
        }
        .frame(width: 520)
        .navigationTitle(isNew ? "Create Quick Link" : "Edit Quick Link")
    }
}
