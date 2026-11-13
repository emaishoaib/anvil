public enum NameMatch: Int, Sendable {
    case namePrefix, wordPrefix, everyWordPrefix, contains

    public init?(name: String, query: String) {
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .anchored]
        let nameWords = Self.words(in: name)
        let queryWords = Self.words(in: query)
        if name.range(of: query, options: options) != nil {
            self = .namePrefix
        } else if nameWords.contains(where: { $0.range(of: query, options: options) != nil }) {
            self = .wordPrefix
        } else if !queryWords.isEmpty, queryWords.allSatisfy({ queryWord in nameWords.contains { $0.range(of: queryWord, options: options) != nil } }) {
            self = .everyWordPrefix
        } else if name.localizedStandardContains(query) {
            self = .contains
        } else {
            return nil
        }
    }

    private static func words(in text: String) -> [Substring] {
        text.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
    }
}
