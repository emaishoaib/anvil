import SwiftUI

/// A code block from Claude's answer, in a monospaced font inside a tinted box, with its language above it when Claude named one. Long lines scroll sideways instead of wrapping, so code and box-drawing diagrams keep their shape.
struct CodeBlockView: View {
    private static let cornerRadius: CGFloat = 8

    let language: String?
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let language, !language.isEmpty {
                Text(language)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding([.horizontal, .top], 10)
            }
            ScrollView(.horizontal) {
                Text(code)
                    .font(.system(.callout, design: .monospaced))
                    .fixedSize()
                    .padding(10)
            }
            .scrollIndicators(.never)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.primary.opacity(0.05), in: .rect(cornerRadius: Self.cornerRadius))
    }
}
