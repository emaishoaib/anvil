public enum RuleTrigger: Hashable, Codable, Sendable {
    case shortcut(Keystroke)
    case mouseButton(number: Int)
    case appOpens
    case appComesToFront
}
