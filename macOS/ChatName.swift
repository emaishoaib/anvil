import SwiftUI

/// The chat's name at the top of AI mode, or the word Chat before a chat starts. Clicking the name turns it into a field for a new one, which is kept when Return is pressed or the field loses focus, and dropped with Escape.
struct ChatName: View {
    @Bindable var model: SearchModel
    @FocusState private var isFocused: Bool

    var body: some View {
        if let draft = Binding($model.chatNameDraft) {
            TextField("Chat Name", text: draft)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onAppear { isFocused = true }
                .onChange(of: isFocused) { if !isFocused { model.renameChat() } }
        } else {
            Text(model.chat?.title ?? "Chat")
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .onTapGesture(perform: model.startRenamingChat)
        }
    }
}
