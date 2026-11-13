public enum NameMatch: Int, Sendable {
    case namePrefix, wordPrefix, contains

    public init?(name: String, query: String) {
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .anchored]
        if name.range(of: query, options: options) != nil {
            self = .namePrefix
        } else if name.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).contains(where: { $0.range(of: query, options: options) != nil }) {
            self = .wordPrefix
        } else if name.localizedStandardContains(query) {
            self = .contains
        } else {
            return nil
        }
    }
}
