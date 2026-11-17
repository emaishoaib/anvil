import SwiftUI

/// The question shown at the end of an unsaved chat when leaving it, since leaving moves the chat's files to the Trash. Return leaves, Command S saves the chat and then leaves, Escape goes back to chatting, and the buttons do the same.
struct LeaveChatCard: View {
    private static let cornerRadius: CGFloat = 10

    let keepChatting: () -> Void
    let save: () -> Void
    let leave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Leave without saving?", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.headline)
            Text("This chat isn't saved, so leaving moves it to the Trash.")
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Spacer()
                Button("Keep Chatting", action: keepChatting)
                Button("Save and Leave", action: save)
                Button("Leave", role: .destructive, action: leave)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.secondary.opacity(0.4)))
    }
}
