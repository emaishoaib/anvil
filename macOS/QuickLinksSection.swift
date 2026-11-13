import LauncherKit
import SwiftUI

struct QuickLinksSection: View {
    private let library = QuickLinkLibrary.shared
    @State private var editing: QuickLink?
    @State private var deleting: QuickLink?

    var body: some View {
        Section("Quick Links") {
            if library.links.isEmpty {
                Text("No quick links yet").foregroundStyle(.secondary)
            }
            ForEach(library.links) { link in
                QuickLinkRow(link: link, edit: { editing = link }, delete: { deleting = link })
            }
            Button("Add Quick Link…") { editing = QuickLink() }
        }
        .sheet(item: $editing) { link in
            QuickLinkEditor(link: link, isNew: !library.contains(link), save: library.save)
        }
        .confirmationDialog("Delete \(deleting?.name ?? "")?", isPresented: isConfirmingDelete, presenting: deleting) { link in
            Button("Delete Quick Link", role: .destructive) { library.delete(link) }
        } message: { _ in
            Text("This can't be undone.")
        }
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding(
            get: { deleting != nil },
            set: { if !$0 { deleting = nil } }
        )
    }
}

private struct QuickLinkRow: View {
    let link: QuickLink
    let edit: () -> Void
    let delete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            QuickLinkIcon(link: link)
            VStack(alignment: .leading, spacing: 2) {
                Text(link.name)
                Text(link.link)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Button("Edit", systemImage: "pencil", action: edit)
            Button("Delete", systemImage: "trash", action: delete)
        }
        .buttonStyle(.borderless)
        .labelStyle(.iconOnly)
        .contentShape(.rect)
        .onTapGesture(count: 2, perform: edit)
    }
}
