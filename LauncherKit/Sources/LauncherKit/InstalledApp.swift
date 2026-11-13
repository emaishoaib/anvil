import Foundation

public struct InstalledApp: Identifiable, Hashable, Sendable {
    public let name: String
    public let url: URL

    public var id: URL { url }

    public init(url: URL) {
        self.url = url
        name = url.deletingPathExtension().lastPathComponent
    }

    public func match(for query: String) -> AppMatch? {
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .anchored]
        if name.range(of: query, options: options) != nil { return .namePrefix }
        let words = name.split { !$0.isLetter && !$0.isNumber }
        if words.contains(where: { $0.range(of: query, options: options) != nil }) { return .wordPrefix }
        return name.localizedStandardContains(query) ? .contains : nil
    }
}
