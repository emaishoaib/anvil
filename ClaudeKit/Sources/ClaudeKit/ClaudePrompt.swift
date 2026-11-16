import Foundation

/// A prompt written as the one line of stream JSON that Claude Code reads as a new message from the user, ending in a newline so Claude Code knows the line is complete.
public enum ClaudePrompt {
    public static func line(_ text: String) -> Data {
        let message: [String: Any] = ["type": "user", "message": ["role": "user", "content": text]]
        let json = (try? JSONSerialization.data(withJSONObject: message)) ?? Data()
        return json + Data("\n".utf8)
    }
}
