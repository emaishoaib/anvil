import SwiftUI

/// The area under the prompt in AI mode, where the chat with Claude Code appears. Until a prompt is sent it says what the field is for.
struct ClaudeChat: View {
    private static let height: CGFloat = 396

    var body: some View {
        Text("Type a prompt for Claude Code")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: Self.height)
    }
}
