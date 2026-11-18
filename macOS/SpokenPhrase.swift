import ClaudeKit
import Foundation

/// The two phrases that, said first, name the session a voice prompt goes to. Each is saved in the user defaults and edited in its own form.
enum SpokenPhrase: CaseIterable {
    case newSession
    case lastSession

    var title: String {
        switch self {
        case .newSession: "New Session Phrase"
        case .lastSession: "Last Session Phrase"
        }
    }

    var hint: String {
        switch self {
        case .newSession: "Start what you say with this to send it to a new session. It is left out of what is sent."
        case .lastSession: "Start what you say with this to send it to the last session you used. It is left out of what is sent."
        }
    }

    var current: String {
        UserDefaults.standard.string(forKey: savedKey) ?? defaultPhrase
    }

    /// Saves the phrase, unless it is empty or the same as the other one, since then the two could not be told apart. Whether it was saved.
    func save(_ phrase: String) -> Bool {
        let phrase = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        let others = Self.allCases.filter { $0 != self }.map(\.current)
        guard !phrase.isEmpty, !others.contains(where: { $0.caseInsensitiveCompare(phrase) == .orderedSame }) else { return false }
        UserDefaults.standard.set(phrase, forKey: savedKey)
        return true
    }

    private var savedKey: String {
        switch self {
        case .newSession: "ai.newSessionPhrase"
        case .lastSession: "ai.lastSessionPhrase"
        }
    }

    private var defaultPhrase: String {
        switch self {
        case .newSession: "new session"
        case .lastSession: "last session"
        }
    }

    /// Splits what was said into the session it names and the prompt, using the saved phrases and where unnamed speech goes.
    static func prompt(in said: String) -> SpokenPrompt {
        SpokenPrompt(said, newSessionPhrase: newSession.current, lastSessionPhrase: lastSession.current, unnamed: UnnamedSpeech.session)
    }
}

/// Where a voice prompt goes when it starts with neither phrase: a new session unless set to the last one. The choice is saved in the user defaults.
enum UnnamedSpeech {
    private static let savedKey = "ai.unnamedSession"

    static var session: SpokenPrompt.Session {
        get { UserDefaults.standard.string(forKey: savedKey).flatMap(SpokenPrompt.Session.init(rawValue:)) ?? .new }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: savedKey) }
    }
}
