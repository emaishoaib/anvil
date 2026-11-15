import RulesKit
import SwiftUI

struct KeySwapsSection: View {
    private let library = KeySwapLibrary.shared
    @State private var isAdding = false

    var body: some View {
        Section {
            if let problem = library.loadProblem {
                Label(problem, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
            ForEach(library.swaps) { swap in
                HStack {
                    Text(HIDKeys.name(for: swap.first))
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundStyle(.secondary)
                    Text(HIDKeys.name(for: swap.second))
                    Spacer()
                    Button("Delete", systemImage: "trash") { library.delete(swap) }
                        .buttonStyle(.borderless)
                        .labelStyle(.iconOnly)
                }
            }
            Button("Add Key Swap…") { isAdding = true }
                .disabled(library.loadProblem != nil)
        } header: {
            Text("Key Swaps")
        } footer: {
            Text(KeySwapsCatalog.explanation)
                .foregroundStyle(.secondary)
        }
        .sheet(isPresented: $isAdding) {
            KeySwapEditor(add: library.add)
        }
    }
}

private struct KeySwapEditor: View {
    let add: (KeySwap) -> Void
    @State private var first: Int?
    @State private var second: Int?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Form {
                KeyPicker(title: "Key", selection: $first)
                KeyPicker(title: "Swap With", selection: $second)
            }
            .formStyle(.grouped)
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add Key Swap") {
                    if let first, let second { add(KeySwap(first: first, second: second)) }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(first == nil || second == nil || first == second)
            }
            .padding([.horizontal, .bottom], 20)
        }
        .frame(width: 420)
    }
}
