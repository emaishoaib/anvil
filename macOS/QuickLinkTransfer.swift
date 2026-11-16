import AppKit
import LauncherKit
import UniformTypeIdentifiers

enum QuickLinkTransfer {
    static func importFile() -> String? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.message = "Choose a quick links file"
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        guard let data = try? Data(contentsOf: url), let links = try? QuickLinkFile.decode(data, appNamed: app(named:)) else {
            return "That file isn't a list of quick links."
        }
        let result = QuickLinkLibrary.shared.merge(links)
        var outcomes = ["Added \(count(result.added))"]
        if result.updated > 0 { outcomes.append("updated the app on \(count(result.updated))") }
        if result.skipped > 0 { outcomes.append("skipped \(count(result.skipped)) already in Anvil") }
        return ListFormatter.localizedString(byJoining: outcomes) + "."
    }

    static func exportFile() -> String? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "Anvil Quick Links.json"
        panel.message = "Save your quick links to import into Anvil on another Mac"
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        let links = QuickLinkLibrary.shared.links
        guard let data = try? QuickLinkFile.encode(links), (try? data.write(to: url, options: .atomic)) != nil else {
            return "The quick links couldn't be saved there."
        }
        return "Exported \(count(links.count))."
    }

    private static func app(named name: String) -> URL? {
        AppCatalog.shared.apps.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }?.url
            ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: name)
    }

    private static func count(_ links: Int) -> String {
        links == 1 ? "1 quick link" : "\(links) quick links"
    }
}
