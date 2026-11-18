import SwiftUI

/// The row of buttons along the bottom of a question card, pushed to the right, with the highlighted one drawn filled since that is the one Return presses.
struct ChoiceButtons: View {
    let choices: [CardChoice]
    let highlighted: CardChoice?
    let choose: (CardChoice) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            ForEach(choices, id: \.self) { choice in
                ChoiceButton(choice: choice, isHighlighted: choice == highlighted, choose: choose)
            }
        }
    }
}

private struct ChoiceButton: View {
    let choice: CardChoice
    let isHighlighted: Bool
    let choose: (CardChoice) -> Void

    var body: some View {
        if isHighlighted {
            button.buttonStyle(.borderedProminent)
        } else {
            button.buttonStyle(.bordered)
        }
    }

    private var button: some View {
        Button(choice.title, role: choice.role) { choose(choice) }
    }
}
