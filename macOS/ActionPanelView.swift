import LauncherKit
import SwiftUI

struct ActionPanelView: View {
    private static let width: CGFloat = 400
    private static let titleHeight: CGFloat = 34
    private static let maximumListHeight: CGFloat = 300
    private static let filterHeight: CGFloat = 41
    private static let dividerHeight: CGFloat = 9

    @Bindable var panel: ActionPanel
    let focus: FocusState<SearchField?>.Binding
    let perform: (ActionPanel.Item) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(panel.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .frame(height: Self.titleHeight)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(panel.items.enumerated()), id: \.element) { index, item in
                            if startsGroup(at: index) {
                                Divider().frame(height: Self.dividerHeight)
                            }
                            ActionRow(item: item, link: panel.link, isSelected: index == panel.selected)
                                .id(index)
                                .onTapGesture { perform(item) }
                        }
                    }
                    .padding(.horizontal, 6)
                }
                .frame(height: min(listHeight, Self.maximumListHeight))
                .onChange(of: panel.selected) { proxy.scrollTo(panel.selected) }
            }
            if panel.page != .confirmDelete {
                Divider()
                TextField(panel.filterPlaceholder, text: $panel.filter)
                    .textFieldStyle(.plain)
                    .focused(focus, equals: .actionFilter)
                    .padding(.horizontal, 14)
                    .frame(height: Self.filterHeight - 1)
                    .onAppear { focus.wrappedValue = .actionFilter }
            }
        }
        .frame(width: Self.width)
        .background(.regularMaterial, in: .rect(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.primary.opacity(0.12)))
        .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
    }

    private var listHeight: CGFloat {
        let dividers = panel.items.indices.filter(startsGroup).count
        return CGFloat(panel.items.count) * ActionRow.height + CGFloat(dividers) * Self.dividerHeight + 6
    }

    private func startsGroup(at index: Int) -> Bool {
        guard index > 0, case .action(let action) = panel.items[index], case .action(let previous) = panel.items[index - 1] else { return false }
        return action.group != previous.group
    }
}
