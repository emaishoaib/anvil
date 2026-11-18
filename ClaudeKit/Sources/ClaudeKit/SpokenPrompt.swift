import Foundation

/// What was said by voice, split into the session it is for and the prompt to send. Starting with the new session phrase asks for a new one, starting with the last session phrase means the last one used, and naming no session goes wherever unnamed speech is set to go. A phrase counts only as whole words at the very start, whatever its case, and it is dropped along with the punctuation and spaces after it. An empty phrase never matches.
public struct SpokenPrompt: Equatable, Sendable {
    public enum Session: String, CaseIterable, Sendable {
        case new
        case last
    }

    public let session: Session
    public let text: String

    public init(_ said: String, newSessionPhrase: String, lastSessionPhrase: String, unnamed: Session) {
        let said = said.trimmingCharacters(in: .whitespacesAndNewlines)
        let phrases: [(phrase: String, session: Session)] = [(newSessionPhrase, .new), (lastSessionPhrase, .last)]
        let match = phrases.lazy.compactMap { phrase, session in Self.text(after: phrase, in: said).map { (session, $0) } }.first
        session = match?.0 ?? unnamed
        text = match?.1 ?? said
    }

    private static func text(after phrase: String, in said: String) -> String? {
        let phrase = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phrase.isEmpty, let range = said.range(of: phrase, options: [.caseInsensitive, .anchored]) else { return nil }
        let rest = said[range.upperBound...]
        guard rest.first.map({ !$0.isLetter && !$0.isNumber }) ?? true else { return nil }
        return String(rest.drop { $0.isWhitespace || $0.isPunctuation })
    }
}
