import Foundation

/// A chat's name written as the one line Claude Code and Claude desktop add to a transcript when a chat is named, ending in a newline so it can be added to the end of the transcript as it is. The last such line in a transcript is the chat's name.
public enum TranscriptTitle {
    public static func line(_ title: String, sessionID: UUID) -> Data {
        let entry: [String: Any] = ["type": "custom-title", "customTitle": title, "sessionId": sessionID.uuidString.lowercased()]
        let json = (try? JSONSerialization.data(withJSONObject: entry, options: .withoutEscapingSlashes)) ?? Data()
        return json + Data("\n".utf8)
    }
}
