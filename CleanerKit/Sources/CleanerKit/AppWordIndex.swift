/// The words of many apps' bundle IDs and names, filed under their first word, so a name can be checked against every app at once by looking up each of its words a single time.
struct AppWordIndex: Sendable {
    private struct Entry: Sendable {
        let app: AppIdentity
        let words: [String]
    }

    private let entriesByFirstWord: [String: [Entry]]

    init(apps: [AppIdentity]) {
        let entries = apps.flatMap { app in WalkMatch(app: app).wordSequences.map { Entry(app: app, words: $0) } }
        entriesByFirstWord = Dictionary(grouping: entries) { $0.words[0] }
    }

    /// The apps a name belongs to, under the rule in `WalkMatch`. When it belongs to more than one, only the apps whose words run longest in the name are kept, so `com.google.Chrome.canary` goes to Chrome Canary and not to Chrome.
    func owners(of name: String) -> Set<AppIdentity> {
        let words = WalkMatch.words(in: name)
        var longestRun = 0
        var owners: Set<AppIdentity> = []
        for (start, word) in words.enumerated() {
            for entry in entriesByFirstWord[word] ?? [] where words[start...].starts(with: entry.words) {
                if entry.words.count > longestRun {
                    longestRun = entry.words.count
                    owners = [entry.app]
                } else if entry.words.count == longestRun {
                    owners.insert(entry.app)
                }
            }
        }
        return owners
    }
}
