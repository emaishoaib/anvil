import AppKit
import LauncherKit
import SwiftUI

struct QuickLinkEditor: View {
    let isNew: Bool
    let save: (QuickLink) -> Void
    @State private var draft: QuickLink
    @Environment(\.dismiss) private var dismiss

    init(link: QuickLink, isNew: Bool, save: @escaping (QuickLink) -> Void) {
        self.isNew = isNew
        self.save = save
        _draft = State(initialValue: link)
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                TextField("Name", text: $draft.name, prompt: Text("Quick link name"))
                LinkField(link: $draft.link)
                OpenWithPicker(link: draft, selection: $draft.openWith)
            }
            .formStyle(.grouped)
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isNew ? "Create Quick Link" : "Update Quick Link") {
                    save(draft)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!draft.isComplete)
            }
            .padding([.horizontal, .bottom], 20)
        }
        .frame(width: 520)
        .navigationTitle(isNew ? "Create Quick Link" : "Edit Quick Link")
    }
}

private struct LinkField: View {
    @Binding var link: String

    var body: some View {
        HStack {
            TextField("Link", text: $link, prompt: Text("https://google.com/search?q=…"))
            Button("Choose a File or Folder", systemImage: "folder", action: choose)
                .buttonStyle(.borderless)
                .labelStyle(.iconOnly)
        }
    }

    private func choose() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.message = "Choose a file or folder to open"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        link = (url.path as NSString).abbreviatingWithTildeInPath
    }
}

private struct OpenWithPicker: View {
    let link: QuickLink
    @Binding var selection: URL?

    var body: some View {
        Picker("Open With", selection: $selection) {
            Label { Text(defaultName) } icon: { link.defaultApp.map { Image(nsImage: $0.menuIcon) } }
                .tag(URL?.none)
            ForEach(otherApps, id: \.self) { app in
                Label { Text(app.appName) } icon: { Image(nsImage: app.menuIcon) }
                    .tag(URL?.some(app))
            }
        }
    }

    private var defaultName: String {
        link.defaultApp.map { "\($0.appName) (Default)" } ?? "Default App"
    }

    private var otherApps: [URL] {
        let choices = link.appChoices.filter { $0 != link.defaultApp }
        guard let selection, !choices.contains(selection) else { return choices }
        return choices + [selection]
    }
}
