import Foundation

/// The `claude://` links Claude desktop answers. Resuming a Claude Code session that Claude desktop did not start takes it into Claude desktop's Code sessions, under the same session id.
public enum DesktopLinks {
    public static func resume(_ sessionID: UUID) -> URL {
        var components = URLComponents()
        components.scheme = "claude"
        components.host = "resume"
        components.queryItems = [URLQueryItem(name: "session", value: sessionID.uuidString.lowercased())]
        return components.url!
    }
}
