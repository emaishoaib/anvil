import SwiftUI

/// The editor for one spoken phrase inside the search bar, with what the phrase does under it. Command Return saves.
struct PhraseForm: View {
    private static let fieldWidth: CGFloat = 460

    @Binding var draft: String
    let phrase: SpokenPhrase
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField(phrase.title, text: $draft)
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
                .focused($isFocused)
            Text(phrase.hint)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: Self.fieldWidth)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .onAppear { DispatchQueue.main.async { isFocused = true } }
    }
}
