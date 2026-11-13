import Foundation

public struct RecentWords: Equatable, Sendable {
    public static let limit = 20

    public private(set) var words: [String]

    public init(_ words: [String] = []) {
        self.words = Array(words.prefix(Self.limit))
    }

    public mutating func record(_ word: String) {
        let word = word.trimmingCharacters(in: .whitespaces)
        guard !word.isEmpty else { return }
        words.removeAll { $0.caseInsensitiveCompare(word) == .orderedSame }
        words.insert(word, at: 0)
        words = Array(words.prefix(Self.limit))
    }
}
