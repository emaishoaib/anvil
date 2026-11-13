import LauncherKit
import SwiftUI

struct AnswerCard: View {
    static let height: CGFloat = 124

    let answer: Answer
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 0) {
            AnswerSide(text: answer.input, label: answer.inputLabel)
            AnswerArrow()
            AnswerSide(text: answer.output, label: answer.outputLabel)
        }
        .frame(height: Self.height)
        .background(.primary.opacity(isSelected ? SearchStyle.selectionOpacity : SearchStyle.selectionOpacity / 2), in: .rect(cornerRadius: SearchStyle.cornerRadius + 2))
        .contentShape(.rect)
    }
}

private struct AnswerSide: View {
    let text: String
    let label: String

    var body: some View {
        VStack(spacing: 16) {
            Text(text)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color(nsColor: .textColor))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.primary.opacity(0.1), in: .rect(cornerRadius: 5))
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}

private struct AnswerArrow: View {
    var body: some View {
        VStack(spacing: 10) {
            Rectangle()
                .fill(.primary.opacity(0.12))
                .frame(width: 1)
            Image(systemName: "arrow.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(nsColor: .textColor))
            Rectangle()
                .fill(.primary.opacity(0.12))
                .frame(width: 1)
        }
    }
}
