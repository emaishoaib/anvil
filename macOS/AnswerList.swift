import ClaudeKit
import SwiftUI

/// A list from Claude's answer, each item beside its bullet, or its number when the list is numbered. An item can hold several blocks, including a list of its own.
struct AnswerList: View {
    private static let markerWidth: CGFloat = 22

    let start: Int?
    let items: [[AnswerBlock]]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, blocks in
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(marker(at: index))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(width: Self.markerWidth, alignment: .trailing)
                    AnswerView(blocks: blocks)
                }
            }
        }
    }

    private func marker(at index: Int) -> String {
        guard let start else { return "•" }
        return "\(start + index)."
    }
}
