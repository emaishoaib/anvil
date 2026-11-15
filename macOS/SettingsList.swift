import LauncherKit
import SwiftUI

/// The settings that match the query in settings mode, under a header per tool. Only the rows on screen are built.
struct SettingsList: View {
    private static let rowHeight: CGFloat = 48
    private static let padding: CGFloat = 8
    private static let listHeight: CGFloat = 380

    let model: SettingsBarModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(model.sections) { section in
                        SectionHeader(title: section.title)
                        ForEach(section.settings) { setting in
                            SettingRowView(setting: setting, isSelected: model.isSelected(setting))
                                .frame(height: Self.rowHeight)
                                .id(setting.id)
                                .onTapGesture { model.activate(setting) }
                        }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: Self.listHeight + Self.padding * 2)
            .onChange(of: model.selected) {
                if let id = model.selectedSetting?.id { proxy.scrollTo(id) }
            }
        }
    }
}

private struct SettingRowView: View {
    let setting: Setting
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            SettingTitle(title: setting.entry.title, subtitle: setting.subtitle)
            Spacer()
            SettingControl(row: setting.row)
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}

private struct SettingTitle: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .foregroundStyle(Color(nsColor: .textColor))
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct SettingControl: View {
    let row: SettingRow

    var body: some View {
        switch row {
        case .toggle(let isOn, _):
            Toggle("", isOn: .constant(isOn))
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
                .allowsHitTesting(false)
        }
    }
}
