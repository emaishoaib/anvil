import ClaudeKit
import SwiftUI

/// The area under the prompt in AI mode, where the chat with Claude Code appears, each prompt above its answer, with any approval Claude is waiting for, the offer to update Claude Code when it is too old, or the question about leaving an unsaved chat, at the end. A chat opens scrolled to its end, so a loaded chat shows its latest turn, and while it is scrolled to its end it keeps the newest text in view as the answer streams in. Scrolling up leaves it where it is until it is scrolled back down, or until a prompt is sent or a card shows, which bring the end back into view. It shows the anvil loader while a loaded chat's earlier turns are read, and says what the field is for until a prompt is sent, or asks to sign in when Claude Code is signed out. In the expanded search bar it takes all the height there is.
struct ClaudeChat: View {
    private static let height: CGFloat = 364
    private static let bottomID = "bottom"
    private static let followDistance: CGFloat = 40

    let chat: ClaudeChatSession?
    let state: ChatState
    let update: ClaudeUpdate.State
    let isExpanded: Bool
    let cardChoice: CardChoice?
    let choose: (CardChoice) -> Void

    @State private var isFollowing = true

    var body: some View {
        content
            .frame(height: isExpanded ? nil : Self.height)
            .frame(maxHeight: isExpanded ? .infinity : nil)
    }

    @ViewBuilder private var content: some View {
        if let chat, chat.isLoadingHistory, chat.turns.isEmpty {
            AnvilLoader(size: .regular)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let chat, !chat.turns.isEmpty {
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
                .onScrollGeometryChange(for: ScrollGeometry.self, of: { $0 }) { old, new in
                    guard old.contentSize == new.contentSize else { return }
                    isFollowing = new.contentSize.height - new.visibleRect.maxY < Self.followDistance
                }
                .onChange(of: chat.turns.last?.answer) { follow(proxy) }
                .onChange(of: chat.turns.last?.tools.count) { follow(proxy) }
                .onChange(of: chat.turns.count) { scrollToEnd(proxy) }
                .onChange(of: chat.approvals.first?.requestID) { scrollToEnd(proxy) }
                .onChange(of: state) { scrollToEnd(proxy) }
                .onChange(of: update) { scrollToEnd(proxy) }
            }
        } else if state == .signedOut || state == .signingIn {
            SignInPrompt(isSigningIn: state == .signingIn)
        } else {
            Text("Type a prompt for Claude Code")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func follow(_ proxy: ScrollViewProxy) {
        guard isFollowing else { return }
        proxy.scrollTo(Self.bottomID, anchor: .bottom)
    }

    private func scrollToEnd(_ proxy: ScrollViewProxy) {
        isFollowing = true
        proxy.scrollTo(Self.bottomID, anchor: .bottom)
    }
}

private struct TurnView: View {
    let turn: ChatTurn

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PromptBubble(prompt: turn.prompt, image: turn.image)
            if !turn.tools.isEmpty {
                ChatToolList(tools: turn.tools, isFinished: turn.isFinished)
            }
            if turn.answer.isEmpty, !turn.isFinished {
                AnvilLoader()
            } else if turn.failed {
                Text(turn.answer)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            } else if !turn.answer.isEmpty {
                AnswerView(blocks: turn.readAnswer ?? AnswerMarkdown.blocks(from: turn.answer))
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

/// A prompt the user sent, kept on the right in a bubble tinted with the accent colour so it stands apart from Claude's answers on the left, with the image sent alongside it above the bubble. A long prompt wraps before it reaches the left edge, and an image sent without text shows on its own.
private struct PromptBubble: View {
    private static let cornerRadius: CGFloat = 12
    private static let roomOnLeft: CGFloat = 60
    private static let tintOpacity = 0.18
    private static let imageHeight: CGFloat = 160

    let prompt: String
    let image: Data?

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            if let image, let picture = NSImage(data: image) {
                Image(nsImage: picture)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: Self.imageHeight)
                    .clipShape(.rect(cornerRadius: Self.cornerRadius))
            }
            if !prompt.isEmpty {
                Text(prompt)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.tint.opacity(Self.tintOpacity), in: .rect(cornerRadius: Self.cornerRadius))
                    .textSelection(.enabled)
            }
        }
        .padding(.leading, Self.roomOnLeft)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
