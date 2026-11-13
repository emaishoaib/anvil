import AppKit
import LauncherKit
import SwiftUI

extension QuickLink {
    static let placeholderHint = "Put {Query} in the link to type something in when you open it. The word in the braces is the hint you see, and a link can have up to \(placeholderLimit)."
}

struct LinkField: View {
    @Binding var link: String
    var choose: @MainActor () -> URL? = FilePicker.chooseFileOrFolder

    var body: some View {
        HStack {
            TextField("Link", text: $link, prompt: Text("https://google.com/search?q={Query}"))
            Button("Choose a File or Folder", systemImage: "folder") {
                guard let url = choose() else { return }
                link = (url.path as NSString).abbreviatingWithTildeInPath
            }
            .buttonStyle(.borderless)
            .labelStyle(.iconOnly)
        }
    }
}

struct OpenWithPicker: View {
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

enum FilePicker {
    static func chooseFileOrFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.message = "Choose a file or folder to open"
        return panel.runModal() == .OK ? panel.url : nil
    }
}
