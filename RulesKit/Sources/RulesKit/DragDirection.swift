import Foundation

public enum DragDirection: String, CaseIterable, Codable, Sendable {
    case up, down, left, right

    init?(across: Double, down: Double, thresholdPoints: Double) {
        guard hypot(across, down) >= thresholdPoints else { return nil }
        if abs(across) > abs(down) {
            self = across > 0 ? .right : .left
        } else {
            self = down > 0 ? .down : .up
        }
    }
}
