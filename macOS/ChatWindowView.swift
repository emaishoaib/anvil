import SwiftUI

/// What a chat window shows, laid out like a chat in the search bar: the name and the keys at the top, which also drag the window, the chat filling the middle with any skills offered over its end, the folder and mode under it, and the prompt at the bottom.
struct ChatWindowView: View {
    private static let skillsPadding: CGFloat = 8

    let chat: ChatModel

    var body: some View {
        VStack(spacing: 0) {
            SearchFooter(mode: .askClaude, selected: nil, toggleAnvilActions: {}, chatState: chat.state, cardChoice: chat.cardChoice, isChatSaved: chat.isSaved, chatName: ChatName(chat: chat), dividerEdge: .bottom)
                .gesture(WindowDragGesture())
            ClaudeChat(chat: chat.session, state: chat.state, update: chat.update.state, isExpanded: true, cardChoice: chat.cardChoice, choose: chat.choose)
                .overlay(alignment: .bottom) {
                    if chat.slashCommands.isShowing {
                        SlashCommandList(picker: chat.slashCommands, complete: chat.completeSlashCommand)
                            .padding(Self.skillsPadding)
                    }
                }
            Divider()
            ChatSetupRow(setup: chat.setup, chat: chat.session, isSaved: chat.isSaved)
            ChatPromptField(chat: chat)
        }
    }
}

/// The prompt at the bottom of a chat window, which takes the keyboard when the window opens and again after the chat is renamed.
private struct ChatPromptField: View {
    private static let lineLimit = 6
    private static let minimumHeight: CGFloat = 56

    let chat: ChatModel
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(chat.placeholder, text: prompt, axis: .vertical)
            .lineLimit(1...Self.lineLimit)
            .textFieldStyle(.plain)
            .font(.body)
            .focused($isFocused)
            .padding(.horizontal, 16)
            .frame(minHeight: Self.minimumHeight)
            .onAppear { isFocused = true }
            .onChange(of: chat.nameDraft == nil) { if chat.nameDraft == nil { isFocused = true } }
    }

    /// Writes to the chat only when the text really changed, because the field writes its unchanged text back whenever it loses focus, and that would reset the skills offered.
    private var prompt: Binding<String> {
        Binding(
            get: { chat.prompt },
            set: { if $0 != chat.prompt { chat.prompt = $0 } }
        )
    }
}
