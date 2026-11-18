import Foundation

/// What was said by voice, split into the session it is for and the prompt to send. Starting with "new session" asks for a new one, and starting with "last session", or naming no session at all, means the last one used. The phrase counts only as whole words at the very start, whatever its case, and it is dropped along with the punctuation and spaces after it.
public struct SpokenPrompt: Equatable, Sendable {
    public enum Session: Equatable, Sendable {
        case new
        case last
    }

    private static let phrases: [(phrase: String, session: Session)] = [("new session", .new), ("last session", .last)]

    public let session: Session
    public let text: String

    public init(_ said: String) {
        let said = said.trimmingCharacters(in: .whitespacesAndNewlines)
        let match = Self.phrases.lazy.compactMap { phrase, session in Self.text(after: phrase, in: said).map { (session, $0) } }.first
        session = match?.0 ?? .last
        text = match?.1 ?? said
    }

    private static func text(after phrase: String, in said: String) -> String? {
        guard let range = said.range(of: phrase, options: [.caseInsensitive, .anchored]) else { return nil }
        let rest = said[range.upperBound...]
        guard rest.first.map({ !$0.isLetter && !$0.isNumber }) ?? true else { return nil }
        return String(rest.drop { $0.isWhitespace || $0.isPunctuation })
    }
}
