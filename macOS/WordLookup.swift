import AppKit
import CoreServices
import LauncherKit

enum WordLookup {
    private static let language = "en"

    static func candidates(for query: String) -> [String] {
        let typed = query.trimmingCharacters(in: .whitespaces)
        let completions = NSSpellChecker.shared.completions(
            forPartialWordRange: NSRange(location: 0, length: (typed as NSString).length),
            in: typed,
            language: language,
            inSpellDocumentWithTag: 0
        ) ?? []
        return WordSearch.candidates(typed: typed, completions: completions)
    }

    nonisolated static func words(from candidates: [String]) -> [Word] {
        candidates.compactMap { text in definition(of: text).map { Word(text: text, definition: $0) } }
    }

    static func openInDictionary(_ word: Word) {
        guard let encoded = word.text.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "dict://\(encoded)")
        else { return }
        NSWorkspace.shared.open(url)
    }

    private nonisolated static func definition(of text: String) -> String? {
        let range = CFRange(location: 0, length: (text as NSString).length)
        guard let found = DCSCopyTextDefinition(nil, text as CFString, range)?.takeRetainedValue() as String? else { return nil }
        return found.replacingOccurrences(of: "\n", with: " ")
    }
}
