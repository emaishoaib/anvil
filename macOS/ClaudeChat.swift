import ClaudeKit
import SwiftUI

/// The area under the prompt in AI mode, where the chat with Claude Code appears, each prompt above its answer, with any approval Claude is waiting for, the offer to update Claude Code when it is too old, or the question about leaving an unsaved chat, at the end. A chat opens scrolled to its end, so a loaded chat shows its latest turn, and it keeps the newest text in view as the answer streams in, and says what the field is for until a prompt is sent, or asks to sign in when Claude Code is signed out. In the expanded search bar it takes all the height there is.
struct ClaudeChat: View {
    private static let height: CGFloat = 364
    private static let bottomID = "bottom"

    let chat: ClaudeChatSession?
    let state: ChatState
    let update: ClaudeUpdate.State
    let isExpanded: Bool
    let cardChoice: CardChoice?
    let choose: (CardChoice) -> Void

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
                            ApprovalCard(approval: approval, highlighted: cardChoice, choose: choose)
                        }
                        if update != .notNeeded {
                            UpdateCard(state: update)
                        }
                        if state == .askingToLeave {
                            LeaveChatCard(highlighted: cardChoice, choose: choose)
                        }
                        Color.clear.frame(height: 1).id(Self.bottomID)
                    }
                    .padding(16)
                }
                .defaultScrollAnchor(.bottom, for: .initialOffset)
                .onChange(of: chat.turns.last?.answer) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: chat.turns.count) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: chat.turns.last?.tools.count) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: chat.approvals.first?.requestID) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: state) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
                .onChange(of: update) { proxy.scrollTo(Self.bottomID, anchor: .bottom) }
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
