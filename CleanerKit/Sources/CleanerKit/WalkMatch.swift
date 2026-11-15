/// Whether a name found anywhere on the Mac belongs to an app, judged by the words in it. A word is a run of letters and digits, ignoring letter case, so `com.apple.WebKit.GPU+com.raycast.macos` has the words `com apple webkit gpu com raycast macos`.
///
/// A name belongs when its words hold, one right after another, all the words of one of these:
/// - the app's bundle ID, the bundle ID of a helper inside it, or one of its app groups
/// - the app's name, or the app's name with its spaces taken out, so `Visual Studio Code` also finds `VisualStudioCode`
///
/// Matching whole words keeps the app's name from being found inside a longer word, such as `Raycast` inside `ARRaycastQuery`. Only the app's own name is used, not its other names, because a short other name such as `Code` would be found all over the Mac. A name with fewer than three letters is not used either. Apple's own apps are never matched, because their names, such as `Notes`, are everyday words.
struct WalkMatch {
    private static let minimumLetterCount = 3

    let wordSequences: [[String]]

    init(app: AppIdentity) {
        guard !app.isApple else {
            wordSequences = []
            return
        }
        let nameWords = Self.words(in: app.name)
        let candidates = app.identifiers.map(Self.words(in:)) + [nameWords, [nameWords.joined()]]
        wordSequences = Array(Set(candidates)).filter { $0.joined().count >= Self.minimumLetterCount }
    }

    func matches(_ name: String) -> Bool {
        matches(words: Self.words(in: name))
    }

    func matches(words: [String]) -> Bool {
        wordSequences.contains { Self.words(words, holdInARow: $0) }
    }

    static func words(in name: String) -> [String] {
        name.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init)
    }

    private static func words(_ words: [String], holdInARow sequence: [String]) -> Bool {
        guard !sequence.isEmpty, sequence.count <= words.count else { return false }
        return (0...(words.count - sequence.count)).contains { start in
            words[start..<start + sequence.count].elementsEqual(sequence)
        }
    }
}
