import Foundation

public enum QuickLinkFile {
    private struct Entry: Codable {
        var name: String
        var link: String
        var openWith: String?
    }

    public static func decode(_ data: Data, appNamed: (String) -> URL?) throws -> [QuickLink] {
        try JSONDecoder().decode([Entry].self, from: data).map { entry in
            QuickLink(name: entry.name, link: entry.link, openWith: entry.openWith.flatMap(appNamed))
        }
    }

    public static func encode(_ links: [QuickLink]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(links.map { link in
            Entry(name: link.name, link: link.link, openWith: link.openWith?.deletingPathExtension().lastPathComponent)
        })
    }
}
