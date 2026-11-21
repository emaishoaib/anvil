import SwiftUI

/// The screenshot page's content: the screenshot shown whole above what can be done with it. Clicking an action selects it.
struct ScreenshotView: View {
    private static let previewHeight: CGFloat = 240
    private static let rowHeight: CGFloat = 40
    private static let padding: CGFloat = 8

    let page: ScreenshotPage
    let query: String

    var body: some View {
        VStack(spacing: 0) {
            if let image = NSImage(data: page.png) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: Self.previewHeight)
                    .clipShape(.rect(cornerRadius: SearchStyle.cornerRadius))
                    .padding(12)
            }
            Divider()
            VStack(spacing: 0) {
                ForEach(Array(page.actions(matching: query).enumerated()), id: \.element) { index, action in
                    ScreenshotActionRow(action: action, isSelected: index == page.selected)
                        .frame(height: Self.rowHeight)
                        .onTapGesture { page.select(index) }
                }
            }
            .padding(Self.padding)
        }
    }
}

private struct ScreenshotActionRow: View {
    let action: ScreenshotAction
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: action.symbol)
                .foregroundStyle(.secondary)
                .frame(width: 22)
            Text(action.title)
                .foregroundStyle(Color(nsColor: .textColor))
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}
