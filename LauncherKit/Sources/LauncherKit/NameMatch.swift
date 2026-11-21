public enum NameMatch: Int, Sendable {
    case namePrefix, wordPrefix, everyWordPrefix, contains, hostWordPrefix

    private static let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .anchored]

    public init?(name: String, query: String) {
        let nameWords = Self.words(in: name)
        if name.range(of: query, options: Self.options) != nil {
            self = .namePrefix
        } else if nameWords.contains(where: { $0.range(of: query, options: Self.options) != nil }) {
            self = .wordPrefix
        } else if Self.everyWord(of: query, startsOneOf: nameWords) {
            self = .everyWordPrefix
        } else if name.localizedStandardContains(query) {
            self = .contains
        } else {
            return nil
        }
    }

    /// A match where every word of the query starts a word in either the name or the host, such as "asig gov" for "asig uk tax" at tax.service.gov.uk.
    public init?(name: String, host: String, query: String) {
        guard Self.everyWord(of: query, startsOneOf: Self.words(in: name) + Self.words(in: host)) else { return nil }
        self = .hostWordPrefix
    }

    var isByName: Bool { self != .hostWordPrefix }

    private static func everyWord(of query: String, startsOneOf words: [Substring]) -> Bool {
        let queryWords = Self.words(in: query)
        guard !queryWords.isEmpty else { return false }
        return queryWords.allSatisfy { queryWord in words.contains { $0.range(of: queryWord, options: options) != nil } }
    }

    private static func words(in text: String) -> [Substring] {
        text.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
    }
}
