import ClaudeKit
import SwiftUI

/// The area under the prompt in AI mode, where the chat with Claude Code appears, each prompt above its answer, with any approval Claude is waiting for, or the question about keeping the chat, at the end. It keeps the newest text in view as the answer streams in, and says what the field is for until a prompt is sent, or asks to sign in when Claude Code is signed out. In the expanded search bar it takes all the height there is.
struct ClaudeChat: View {
    private static let height: CGFloat = 364
    private static let bottomID = "bottom"

    let chat: ClaudeChatSession?
    let state: ChatState
    let isExpanded: Bool
    let save: () -> Void
    let discard: () -> Void

    var body: some View {
        content
            .frame(height: isExpanded ? nil : Self.height)
            .frame(maxHeight: isExpanded ? .infinity : nil)
    }

    @ViewBuilder private var content: some View {
        if let chat, !chat.turns.isEmpty {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(chat.turns) { TurnView(turn: $0) }
                        if let approval = chat.approvals.first {
                            ApprovalCard(approval: approval, answer: { chat.answerApproval(allowed: $0) })
                        }
                        if state == .askingToKeep {
                            KeepChatCard(save: save, discard: discard)
                        }
                        Color.clear.frame(height: 1).id(Self.bottomID)
                    }
                    .padding(16)
                }
                .onChange(of: chat.turns.last?.answer) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: chat.turns.count) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: chat.turns.last?.tools.count) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: chat.approvals.first?.requestID) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: state) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
            }
        } else if state == .signedOut || state == .signingIn {
            SignInPrompt(isSigningIn: state == .signingIn)
        } else {
            Text("Type a prompt for Claude Code")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct TurnView: View {
    let turn: ChatTurn

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(turn.prompt)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.primary.opacity(0.06), in: .rect(cornerRadius: 8))
            if !turn.tools.isEmpty {
                ChatToolList(tools: turn.tools, isFinished: turn.isFinished)
            }
            if turn.answer.isEmpty, !turn.isFinished {
                ProgressView()
                    .controlSize(.small)
            } else if turn.failed {
                Text(turn.answer)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            } else if !turn.answer.isEmpty {
                AnswerView(blocks: AnswerMarkdown.blocks(from: turn.answer))
                    .textSelection(.enabled)
            }
            if turn.wasStopped {
                Label("Stopped", systemImage: "stop.circle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
