import SwiftUI

struct SettingsView: View {
    @State private var selection: Tool? = .switcher

    var body: some View {
        NavigationSplitView {
            List(Tool.allCases, selection: $selection) { tool in
                Label(tool.name, systemImage: tool.symbol)
            }
            .navigationSplitViewColumnWidth(190)
        } detail: {
            if let selection {
                ToolPage(tool: selection)
                    .id(selection)
            }
        }
    }
}
