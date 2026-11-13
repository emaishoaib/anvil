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
            switch selection {
            case .general:
                GeneralPage()
            case .tool(let tool):
                ToolPage(tool: tool)
                    .id(tool)
            case nil:
                EmptyView()
            }
        }
        .onAppear {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate()
        }
        .onDisappear {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
