import Foundation

/// The one line of stream JSON that stops the answer Claude Code is giving, the same as pressing Escape in Claude Code. The chat stays open for the next prompt.
public enum ClaudeInterrupt {
    public static func line(requestID: String = UUID().uuidString) -> Data {
        let request: [String: Any] = ["type": "control_request", "request_id": requestID, "request": ["subtype": "interrupt"]]
        let json = (try? JSONSerialization.data(withJSONObject: request)) ?? Data()
        return json + Data("\n".utf8)
    }
}
