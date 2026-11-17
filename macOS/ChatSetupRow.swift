import ClaudeKit
import SwiftUI

/// The strip under the prompt in AI mode that shows the folder the chat works in, its permission mode, and whether the chat is saved. Clicking the folder picks another one, and clicking the mode moves on to the next, the same as the footer's shortcuts. A chat keeps one folder, so the folder is locked once there is a chat, including one carried on from the saved chats. The mode is locked once Claude Code has started for the chat.
struct ChatSetupRow: View {
    private static let height: CGFloat = 32

    let setup: ChatSetup
    let chat: ClaudeChatSession?
    let isSaved: Bool

    var body: some View {
        HStack(spacing: 16) {
            Button { SearchBar.shared.presentModal(setup.chooseFolder) } label: {
                Label(displayPath, systemImage: "folder")
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .help("Choose the folder Claude Code works in")
            .disabled(chat != nil)
            Spacer()
            if isSaved {
                Label(savedTitle, systemImage: "checkmark.circle")
                    .foregroundStyle(Color.accentColor)
                    .help("This chat is in your saved chats and is saved again after every prompt")
            }
            Button(action: setup.useNextMode) {
                Label(mode.title, systemImage: "checkmark.shield")
            }
            .help(mode.summary)
            .disabled(chat?.mode != nil)
        }
        .buttonStyle(.plain)
        .font(.callout)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .frame(height: Self.height)
    }

    private var displayPath: String {
        ((chat?.folder ?? setup.folder).path as NSString).abbreviatingWithTildeInPath
    }

    private var savedTitle: String {
        chat == nil ? "Saves once you send" : "Saved, keeps saving as you chat"
    }

    private var mode: PermissionMode {
        chat?.mode ?? setup.mode
    }
}
