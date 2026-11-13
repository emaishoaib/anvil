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
            ShownSettingsPage(page: selection)
                .navigationTitle(selection?.title ?? "")
        }
    }
}
