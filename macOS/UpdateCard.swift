import SwiftUI

/// The card at the end of a chat when Claude Code is too old for the options Anvil starts it with. It offers to update Claude Code with Return, shows the update while it runs, and then says to send the prompt again, or that the update failed and how to try again.
struct UpdateCard: View {
    private static let cornerRadius: CGFloat = 10

    let state: ClaudeUpdate.State

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.headline)
            HStack(spacing: 8) {
                if state == .updating {
                    ProgressView()
                        .controlSize(.small)
                }
                Text(detail)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.secondary.opacity(0.4)))
    }

    private var title: String {
        switch state {
        case .notNeeded, .needed: "Claude Code needs an update"
        case .updating: "Updating Claude Code"
        case .updated: "Claude Code is up to date"
        case .failed: "Claude Code couldn't update"
        }
    }

    private var detail: String {
        switch state {
        case .notNeeded, .needed: "This version is too old for Anvil. Press Return to update it."
        case .updating: "This can take a minute."
        case .updated: "Send your prompt again."
        case .failed: "Press Return to try again, or run claude update in Terminal."
        }
    }

    private var symbol: String {
        switch state {
        case .notNeeded, .needed, .updating: "arrow.down.circle"
        case .updated: "checkmark.circle"
        case .failed: "exclamationmark.triangle"
        }
    }
}
