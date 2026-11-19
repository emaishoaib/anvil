import Foundation

/// The fields at the top of a skill or command file, between two `---` lines, read as simple `key: value` lines, and the rest of the file after them. A quoted value loses its quotes, and a value spread over the indented lines that follow it, such as one opened with `>` or `|`, is joined into one line with spaces. A file without them has no fields, and all of it is the rest.
public enum FrontMatter {
    private static let fence = "---"
    private static let blockMarkers: Set<String> = [">", ">-", ">+", "|", "|-", "|+"]

    public static func fields(in contents: String) -> [String: String] {
        guard let (fieldLines, _) = split(contents) else { return [:] }
        var fields: [String: String] = [:]
        var currentKey: String?
        for line in fieldLines {
            if line.first == " " || line.first == "\t" {
                guard let key = currentKey else { continue }
                fields[key] = [fields[key] ?? "", trimmed(line)].filter { !$0.isEmpty }.joined(separator: " ")
                continue
            }
            guard let colon = line.firstIndex(of: ":") else { continue }
            let key = trimmed(line[..<colon])
            let value = trimmed(line[line.index(after: colon)...])
            currentKey = key
            fields[key] = blockMarkers.contains(value) ? "" : unquoted(value)
        }
        return fields
    }

    public static func body(of contents: String) -> String {
        split(contents)?.body ?? contents
    }

    private static func split(_ contents: String) -> (fieldLines: ArraySlice<Substring>, body: String)? {
        let lines = contents.split(separator: "\n", omittingEmptySubsequences: false)
        guard let first = lines.first, trimmed(first) == fence, let end = lines.dropFirst().firstIndex(where: { trimmed($0) == fence }) else { return nil }
        return (lines[1..<end], lines[(end + 1)...].joined(separator: "\n"))
    }

    private static func trimmed(_ text: some StringProtocol) -> String {
        text.trimmingCharacters(in: .whitespaces)
    }

    private static func unquoted(_ value: String) -> String {
        guard value.count >= 2, let first = value.first, first == value.last, first == "\"" || first == "'" else { return value }
        return String(value.dropFirst().dropLast())
    }
}
