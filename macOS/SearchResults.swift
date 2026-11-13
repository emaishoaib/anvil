import LauncherKit
import SwiftUI

struct SearchResults: View {
    private static let rowHeight: CGFloat = 40
    private static let visibleRows = 8
    private static let padding: CGFloat = 8

    let model: SearchModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(model.results.enumerated()), id: \.element.id) { index, app in
                        ResultRow(app: app, isSelected: index == model.selected)
                            .frame(height: Self.rowHeight)
                            .id(index)
                            .onTapGesture { model.open(app) }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: CGFloat(min(model.results.count, Self.visibleRows)) * Self.rowHeight + Self.padding * 2)
            .onChange(of: model.selected) { proxy.scrollTo(model.selected) }
        }
    }
}

private struct ResultRow: View {
    private static let iconSize: CGFloat = 22
    private static let selectionOpacity = 0.07

    let app: InstalledApp
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.path))
                .resizable()
                .frame(width: Self.iconSize, height: Self.iconSize)
            Text(app.name)
            Spacer()
            Text("Application")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: 8).fill(.primary.opacity(Self.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}
