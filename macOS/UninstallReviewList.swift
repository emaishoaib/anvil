import CleanerKit
import LauncherKit
import SwiftUI

/// The rows of the uninstall page: the app and each leftover file, with a tick box, where it lives and its size. A row is ticked or unticked by clicking it. Without Full Disk Access, a notice above the rows says some leftovers may be missing. While the files are being found or moved to the Trash, a spinner stands in for the rows.
struct UninstallReviewList: View {
    private static let rowHeight: CGFloat = 40
    private static let padding: CGFloat = 8
    private static let listHeight: CGFloat = 380

    let review: UninstallReview
    let query: String

    var body: some View {
        Group {
            switch review.state {
            case .searching, .movingToTrash:
                ProgressView()
                    .controlSize(.small)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .ready:
                rows
            }
        }
        .frame(height: Self.listHeight + Self.padding * 2)
    }

    private var rows: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if !review.hasFullDiskAccess { FullDiskAccessNotice() }
                    SectionHeader(title: review.app.name)
                    ForEach(Array(review.items(matching: query).enumerated()), id: \.element.id) { index, item in
                        RemovalRow(item: item, isTicked: review.isTicked(item), isSelected: index == review.selected)
                            .frame(height: Self.rowHeight)
                            .id(index)
                            .onTapGesture {
                                review.select(index)
                                review.toggle(item)
                            }
                    }
                }
                .padding(Self.padding)
            }
            .overlay { if review.items(matching: query).isEmpty { NoResults() } }
            .onChange(of: review.selected) { proxy.scrollTo(review.selected) }
        }
    }
}

private struct FullDiskAccessNotice: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Without Full Disk Access, some leftovers can't be found or moved.")
                .foregroundStyle(.secondary)
            Spacer()
            Button("Open Settings", action: FullDiskAccess.openSettings)
                .controlSize(.small)
        }
        .padding(8)
    }
}

private struct RemovalRow: View {
    let item: RemovalItem
    let isTicked: Bool
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isTicked ? "checkmark.square.fill" : "square")
                .foregroundStyle(isTicked ? Color.accentColor : .secondary)
            AppIcon(path: item.url.path(percentEncoded: false))
            Text(item.name).foregroundStyle(Color(nsColor: .textColor)).lineLimit(1)
            Text(place).foregroundStyle(.secondary).lineLimit(1)
            Spacer()
            Text(item.sizeBytes.formatted(.byteCount(style: .file))).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }

    private var place: String {
        switch item.kind {
        case .app: item.url.deletingLastPathComponent().path(percentEncoded: false)
        case .leftover: ((item.url.path(percentEncoded: false) as NSString).deletingLastPathComponent as NSString).abbreviatingWithTildeInPath
        }
    }
}
