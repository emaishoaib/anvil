import Foundation

public enum FaviconPage {
    private static let unsizedIconPixels = 32
    private static let touchIconPixels = 180
    private static let scalableIconPixels = 256

    public static func iconURLs(in html: String, baseURL: URL) -> [URL] {
        let declared = html.matches(of: /(?i)<link\b[^>]*>/)
            .compactMap { icon(in: String($0.output), baseURL: baseURL) }
            .enumerated()
            .sorted { ($1.element.pixels, $0.offset) < ($0.element.pixels, $1.offset) }
            .map(\.element.url)
        let fallback = URL(string: "/favicon.ico", relativeTo: baseURL)?.absoluteURL
        var seen = Set<URL>()
        return (declared + [fallback].compactMap { $0 }).filter { seen.insert($0).inserted }
    }

    private static func icon(in tag: String, baseURL: URL) -> (url: URL, pixels: Int)? {
        let attributes = attributes(in: tag)
        let rels = (attributes["rel"] ?? "").lowercased().split(whereSeparator: \.isWhitespace)
        let isTouchIcon = rels.contains { $0.hasPrefix("apple-touch-icon") }
        guard isTouchIcon || rels.contains("icon"),
              let href = attributes["href"]?.replacingOccurrences(of: "&amp;", with: "&"),
              let url = URL(string: href, relativeTo: baseURL)?.absoluteURL
        else { return nil }
        return (url, pixels(from: attributes["sizes"]) ?? (isTouchIcon ? touchIconPixels : unsizedIconPixels))
    }

    private static func attributes(in tag: String) -> [String: String] {
        var attributes: [String: String] = [:]
        for match in tag.matches(of: /([A-Za-z-]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))/) {
            let value = match.output.2 ?? match.output.3 ?? match.output.4 ?? ""
            attributes[match.output.1.lowercased()] = String(value)
        }
        return attributes
    }

    private static func pixels(from sizes: String?) -> Int? {
        guard let sizes = sizes?.lowercased() else { return nil }
        if sizes.contains("any") { return scalableIconPixels }
        return sizes.split(whereSeparator: \.isWhitespace).compactMap { size in
            size.split(separator: "x").first.flatMap { Int($0) }
        }.max()
    }
}
