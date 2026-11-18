import Foundation

/// The `claude://` links Claude desktop answers. Resuming a Claude Code session that Claude desktop did not start takes it into Claude desktop's Code sessions, under the same session id, and opens it there. Continuing opens a session Claude desktop already has, named by Claude desktop's own id for it.
public enum DesktopLinks {
    public static func resume(_ sessionID: UUID) -> URL {
        link(host: "resume", path: "", session: sessionID.uuidString.lowercased())
    }

    public static func open(desktopID: String) -> URL {
        link(host: "code", path: "/continue", session: desktopID)
    }

    private static func link(host: String, path: String, session: String) -> URL {
        var components = URLComponents()
        components.scheme = "claude"
        components.host = host
        components.path = path
        components.queryItems = [URLQueryItem(name: "session", value: session)]
        return components.url!
    }
}
