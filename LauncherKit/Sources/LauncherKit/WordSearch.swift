import Foundation

public enum WordSearch {
    public static let limit = 20

    public static func candidates(typed: String, completions: [String]) -> [String] {
        let typed = typed.trimmingCharacters(in: .whitespaces)
        guard !typed.isEmpty else { return [] }
        var seen = Set<String>()
        return Array(([typed] + completions).filter { seen.insert($0.lowercased()).inserted }.prefix(limit))
    }
}
