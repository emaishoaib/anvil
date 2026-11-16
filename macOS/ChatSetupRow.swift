import ClaudeKit
import SwiftUI

/// The strip under the prompt in AI mode that shows the folder the chat works in, its permission mode, and what happens to the chat when it is left, once that has been decided. Clicking the folder picks another one, and clicking the mode moves on to the next, the same as the footer's shortcuts. The folder and mode are locked once the chat has started, because a chat keeps one folder and one mode.
struct ChatSetupRow: View {
    private static let height: CGFloat = 32

    let setup: ChatSetup
    let isLocked: Bool
    let ending: ChatEnding?

    var body: some View {
        HStack(spacing: 16) {
            Button { SearchBar.shared.presentModal(setup.chooseFolder) } label: {
                Label(setup.displayPath, systemImage: "folder")
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .help("Choose the folder Claude Code works in")
            .disabled(isLocked)
            Spacer()
            switch ending {
            case .save:
                Label("Save on Exit", systemImage: "tray.and.arrow.down")
                    .foregroundStyle(Color.accentColor)
            case .discard:
                Label("Discard on Exit", systemImage: "trash")
                    .foregroundStyle(.red)
            case nil:
                EmptyView()
            }
            Button(action: setup.useNextMode) {
                Label(setup.mode.title, systemImage: "checkmark.shield")
            }
            .help(setup.mode.summary)
            .disabled(isLocked)
        }
        .buttonStyle(.plain)
        .font(.callout)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .frame(height: Self.height)
    }
}
