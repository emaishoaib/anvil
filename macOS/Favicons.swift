import AppKit
import LauncherKit
import Observation

@Observable final class Favicons {
    static let shared = Favicons()

    private static let folder = URL.cachesDirectory.appending(path: "com.mashoaib.anvil/Favicons", directoryHint: .isDirectory)
    private static let timeoutSeconds: TimeInterval = 10
    private static let pageBytesLimit = 500_000

    private(set) var icons: [String: NSImage] = [:]
    @ObservationIgnored private var requested: Set<String> = []

    func icon(for site: URL) -> NSImage? {
        guard let host = site.host() else { return nil }
        if let icon = icons[host] { return icon }
        guard requested.insert(host).inserted else { return nil }
        Task { await load(site, host: host) }
        return nil
    }

    private func load(_ site: URL, host: String) async {
        let file = Self.folder.appending(path: host)
        if let data = try? Data(contentsOf: file), let image = NSImage(data: data) {
            icons[host] = image
            return
        }
        guard let data = await fetch(site), let image = NSImage(data: data) else { return }
        icons[host] = image
        try? FileManager.default.createDirectory(at: Self.folder, withIntermediateDirectories: true)
        try? data.write(to: file, options: .atomic)
    }

    private func fetch(_ site: URL) async -> Data? {
        let page = await download(site)
        let html = page.map { String(decoding: $0.data.prefix(Self.pageBytesLimit), as: UTF8.self) } ?? ""
        for candidate in FaviconPage.iconURLs(in: html, baseURL: page?.url ?? site) {
            guard let icon = await download(candidate), NSImage(data: icon.data) != nil else { continue }
            return icon.data
        }
        return nil
    }

    private func download(_ url: URL) async -> (data: Data, url: URL)? {
        let request = URLRequest(url: url, timeoutInterval: Self.timeoutSeconds)
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse, http.statusCode == 200
        else { return nil }
        return (data, response.url ?? url)
    }
}
