import SwiftUI

/// The tools Claude used for one turn. While Claude is still answering, each one shows as a line with a spinner, a tick or a cross. Once the turn is finished they fold into one line that can be opened again, so the answer stays the focus.
struct ChatToolList: View {
    let tools: [ChatTool]
    let isFinished: Bool
    @State private var isOpen = false

    var body: some View {
        if isFinished {
            DisclosureGroup(isExpanded: $isOpen) {
                lines
            } label: {
                Text(tools.count == 1 ? "Used 1 tool" : "Used \(tools.count) tools")
                    .foregroundStyle(.secondary)
            }
        } else {
            lines
        }
    }

    private var lines: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(tools) { ToolLine(tool: $0) }
        }
    }
}

private struct ToolLine: View {
    private static let iconWidth: CGFloat = 16

    let tool: ChatTool

    var body: some View {
        HStack(spacing: 8) {
            icon
                .frame(width: Self.iconWidth)
            Text(tool.summary)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(.secondary)
        }
        .font(.callout)
    }

    @ViewBuilder private var icon: some View {
        switch tool.state {
        case .running:
            ProgressView()
                .controlSize(.mini)
        case .finished:
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
        case .failed:
            Image(systemName: "xmark")
                .foregroundStyle(.red)
        }
    }
}
