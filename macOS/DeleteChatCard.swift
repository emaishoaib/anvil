import SwiftUI

/// The question shown at the end of a saved chat before deleting it, which takes it off the saved chats and moves its files to the Trash. Return presses the highlighted button, which starts on Delete and moves with left and right, Escape goes back to chatting, and the buttons can be clicked too.
struct DeleteChatCard: View {
    private static let cornerRadius: CGFloat = 10

    let highlighted: CardChoice?
    let choose: (CardChoice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Delete this chat?", systemImage: "trash")
                .font(.headline)
            Text("It comes off your saved chats and moves to the Trash.")
                .foregroundStyle(.secondary)
            ChoiceButtons(choices: CardChoice.deleting, highlighted: highlighted, choose: choose)
        }
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.secondary.opacity(0.4)))
    }
}
