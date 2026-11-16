import ClaudeKit
import SwiftUI

/// Claude Code asking for approval, shown at the end of the chat in an outlined box. A command shows in full and a plan shows as markdown, so either can be read before answering. Return allows and Escape turns it down, and the buttons do the same.
struct ApprovalCard: View {
    private static let cornerRadius: CGFloat = 10
    private static let planHeight: CGFloat = 220

    let approval: Approval
    let answer: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(approval.question, systemImage: "hand.raised.fill")
                .font(.headline)
            switch approval.detail {
            case .command(let command):
                CodeBlockView(language: nil, code: command)
            case .plan(let plan):
                ScrollView {
                    AnswerView(blocks: AnswerMarkdown.blocks(from: plan))
                        .textSelection(.enabled)
                }
                .frame(maxHeight: Self.planHeight)
            case nil:
                EmptyView()
            }
            HStack(spacing: 8) {
                Spacer()
                Button("Deny") { answer(false) }
                Button("Allow") { answer(true) }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.orange.opacity(0.6)))
    }
}
