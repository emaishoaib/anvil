import SwiftUI

/// The editor for a block of zsh inside the search bar. Return starts a new line, so Command Return saves.
struct ShellTextForm: View {
    private static let height: CGFloat = 220

    @Binding var draft: String
    let text: ShellText
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: $draft)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(.background.secondary, in: .rect(cornerRadius: 8))
                .frame(height: Self.height)
                .focused($isFocused)
            Text(text.hint)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .onAppear { DispatchQueue.main.async { isFocused = true } }
    }
}
