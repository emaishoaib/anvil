import SwiftUI

/// The chat's name at the top of AI mode, or the word Chat before a chat starts. Clicking the name turns it into a field for a new one, which is kept when Return is pressed or the field loses focus, and dropped with Escape.
struct ChatName: View {
    @Bindable var chat: ChatModel
    @FocusState private var isFocused: Bool

    var body: some View {
        if let draft = Binding($chat.nameDraft) {
            TextField("Chat Name", text: draft)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onAppear { isFocused = true }
                .onChange(of: isFocused) { if !isFocused { chat.rename() } }
        } else {
            Text(chat.session?.title ?? "Chat")
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .onTapGesture(perform: chat.startRenaming)
        }
    }
}
