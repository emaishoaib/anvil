import Foundation

/// Whether Claude Code is signed in, read from what `claude auth status --json` prints. Output that cannot be read gives no answer, rather than a guess either way.
public enum ClaudeAuthStatus {
    private struct Status: Decodable {
        let loggedIn: Bool
    }

    public static func isSignedIn(_ output: Data) -> Bool? {
        (try? JSONDecoder().decode(Status.self, from: output))?.loggedIn
    }
}
