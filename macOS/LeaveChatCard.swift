import SwiftUI

/// The question shown at the end of an unsaved chat when leaving it, since leaving moves the chat's files to the Trash. Return presses the highlighted button, which starts on Leave and moves with left and right, Command S saves the chat and then leaves, Escape goes back to chatting, and the buttons can be clicked too.
struct LeaveChatCard: View {
    private static let cornerRadius: CGFloat = 10

    let highlighted: CardChoice?
    let choose: (CardChoice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Leave without saving?", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.headline)
            Text("This chat isn't saved, so leaving moves it to the Trash.")
                .foregroundStyle(.secondary)
            ChoiceButtons(choices: CardChoice.leaving, highlighted: highlighted, choose: choose)
        }
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.secondary.opacity(0.4)))
    }
}
