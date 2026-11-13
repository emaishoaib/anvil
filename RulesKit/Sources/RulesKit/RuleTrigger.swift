public enum RuleTrigger: Hashable, Codable, Sendable {
    case shortcut(Keystroke)
    case mouseButton(number: Int)
    case mouseDrag(number: Int, direction: DragDirection)
    case appOpens
    case appComesToFront
}
