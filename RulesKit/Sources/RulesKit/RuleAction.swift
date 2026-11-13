import Foundation

public enum RuleAction: Hashable, Codable, Sendable {
    case sendShortcut(Keystroke)
    case chooseMenuItem(path: [String])
    case playSound(name: String)
    case quitApp

    public static func menuPath(from text: String) -> [String] {
        text.split(separator: ">").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}
