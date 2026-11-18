import AppKit
import ClaudeKit

/// Hands chats over to Claude desktop through the links it answers. They are opened without bringing any app forward, so the chat stays where it is.
enum ClaudeDesktop {
    /// Saves a chat into Claude desktop's Code sessions. A chat with nothing sent yet has no session for Claude desktop to take, and one Claude desktop already has is left alone, since taking it again fails.
    static func save(_ sessionID: UUID) {
        guard ClaudeSessionFiles.transcript(of: sessionID) != nil, !DesktopSessionFiles.contains(sessionID) else { return }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false
        NSWorkspace.shared.open(DesktopLinks.resume(sessionID), configuration: configuration)
    }
}
