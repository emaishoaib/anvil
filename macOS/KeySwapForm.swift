import SwiftUI

/// The key swap editor inside the search bar: the two keys to swap on the built-in keyboard.
struct KeySwapForm: View {
    @Binding var draft: KeySwapDraft

    var body: some View {
        Form {
            Section {
                KeyPicker(title: "Key", selection: $draft.first)
                KeyPicker(title: "Swap With", selection: $draft.second)
            } footer: {
                Text(KeySwapsCatalog.explanation)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .fixedSize(horizontal: false, vertical: true)
    }
}
