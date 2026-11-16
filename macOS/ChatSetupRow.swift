import ClaudeKit
import SwiftUI

/// The strip under the prompt in AI mode that shows the folder the chat works in and its permission mode. Clicking the folder picks another one, and clicking the mode moves on to the next, the same as the footer's shortcuts. Both are locked once the chat has started, because a chat keeps one folder and one mode.
struct ChatSetupRow: View {
    private static let height: CGFloat = 32

    let setup: ChatSetup
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 16) {
            Button { SearchBar.shared.presentModal(setup.chooseFolder) } label: {
                Label(setup.displayPath, systemImage: "folder")
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .help("Choose the folder Claude Code works in")
            Spacer()
            Button(action: setup.useNextMode) {
                Label(setup.mode.title, systemImage: "checkmark.shield")
            }
            .help(setup.mode.summary)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
        .font(.callout)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .frame(height: Self.height)
    }
}
