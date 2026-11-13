import SwiftUI

struct SettingsView: View {
    @State private var selection: SettingsPage? = .tool(.switcher)

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Label("General", systemImage: "gearshape")
                    .tag(SettingsPage.general)
                Section("Tools") {
                    ForEach(Tool.allCases) { tool in
                        Label(tool.name, systemImage: tool.symbol)
                            .tag(SettingsPage.tool(tool))
                    }
                }
            }
            .navigationSplitViewColumnWidth(190)
        } detail: {
            ZStack {
                ForEach(SettingsPage.all, id: \.self) { page in
                    PrebuiltPage(page: page, isShown: page == selection)
                }
            }
            .navigationTitle(selection?.title ?? "")
        }
    }
}

/// A settings page built along with the window and only hidden while another page is shown, so choosing it never waits for it to be built.
private struct PrebuiltPage: View {
    let page: SettingsPage
    let isShown: Bool

    var body: some View {
        Group {
            switch page {
            case .general: GeneralPage()
            case .tool(let tool): ToolPage(tool: tool)
            }
        }
        .opacity(isShown ? 1 : 0)
        .allowsHitTesting(isShown)
        .accessibilityHidden(!isShown)
        .zIndex(isShown ? 1 : 0)
    }
}
