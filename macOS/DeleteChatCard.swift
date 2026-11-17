import SwiftUI

/// The question shown at the end of a saved chat before deleting it, which takes it off the saved chats and moves its files to the Trash. Return deletes, Escape goes back to chatting, and the buttons do the same.
struct DeleteChatCard: View {
    private static let cornerRadius: CGFloat = 10

    let keepChatting: () -> Void
    let delete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Delete this chat?", systemImage: "trash")
                .font(.headline)
            Text("It comes off your saved chats and moves to the Trash.")
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Spacer()
                Button("Keep Chatting", action: keepChatting)
                Button("Delete", role: .destructive, action: delete)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.secondary.opacity(0.4)))
    }
}
