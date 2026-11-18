import LauncherKit
import SwiftUI

/// The first page of settings mode while nothing is typed: General and the tools as a grid of one-colour icons, a row at a time, in the style of the old System Preferences. Clicking a tool opens its page, the same as Return on the selected one, and a tool with nothing behind it yet is greyed out. The grid is as tall as the settings list, so the search bar keeps its size when a page opens.
struct SettingsGrid: View {
    private static let padding: CGFloat = 8
    private static let spacing: CGFloat = 6

    let model: SettingsBarModel
    let open: (Setting) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: model.page.breadcrumb)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Self.spacing), count: SettingsBarModel.gridColumns), spacing: Self.spacing) {
                ForEach(model.sections.flatMap(\.settings)) { setting in
                    ToolTile(setting: setting, isSelected: model.isSelected(setting))
                        .onTapGesture { open(setting) }
                }
            }
        }
        .padding(Self.padding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: SettingsList.height, alignment: .top)
    }
}

/// One tool in the grid: its icon on a square tile with its name underneath. General is the one page that is not a tool, so any name that is not a tool's gets General's icon.
private struct ToolTile: View {
    private static let iconSize: CGFloat = 28
    private static let tileSize: CGFloat = 52
    private static let tileCornerRadius: CGFloat = 12
    private static let tileFillOpacity = 0.05
    private static let tileBorderOpacity = 0.15
    private static let disabledOpacity = 0.4

    let setting: Setting
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ToolIconView(icon: Tool.named(setting.entry.title)?.icon ?? GeneralCatalog.icon, size: Self.iconSize)
                .frame(width: Self.tileSize, height: Self.tileSize)
                .background(.primary.opacity(Self.tileFillOpacity), in: .rect(cornerRadius: Self.tileCornerRadius))
                .overlay(RoundedRectangle(cornerRadius: Self.tileCornerRadius).strokeBorder(.primary.opacity(Self.tileBorderOpacity)))
            Text(setting.entry.title)
                .lineLimit(1)
        }
        .foregroundStyle(Color(nsColor: .textColor))
        .opacity(setting.isDisabled ? Self.disabledOpacity : 1)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}
