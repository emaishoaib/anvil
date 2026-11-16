import Foundation

/// The one line of stream JSON that answers an approval Claude Code asked for. Allowing lets the tool run as Claude asked. Turning it down tells Claude why, so it can try another way or ask in its answer.
public enum ApprovalAnswer {
    private static let deniedMessage = "The user turned this down."

    public static func line(for approval: Approval, allowed: Bool) -> Data {
        let decision: [String: Any] = allowed ? ["behavior": "allow"] : ["behavior": "deny", "message": deniedMessage]
        let answer: [String: Any] = [
            "type": "control_response",
            "response": ["subtype": "success", "request_id": approval.requestID, "response": decision],
        ]
        let json = (try? JSONSerialization.data(withJSONObject: answer)) ?? Data()
        return json + Data("\n".utf8)
    }
}
