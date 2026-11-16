import SwiftUI

/// The question shown at the end of the chat when leaving it: keep the chat for later, or discard it. Saving keeps it in Claude Code and in Anvil's saved chats, and discarding moves its files to the Trash. Return saves, Command Delete discards, and the buttons do the same.
struct KeepChatCard: View {
    private static let cornerRadius: CGFloat = 10

    let save: () -> Void
    let discard: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Keep this chat?", systemImage: "tray.and.arrow.down.fill")
                .font(.headline)
            Text("Saving keeps it in Claude Code so you can carry on later. Discarding moves it to the Trash.")
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Spacer()
                Button("Discard", role: .destructive, action: discard)
                Button("Save Chat", action: save)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.secondary.opacity(0.4)))
    }
}
