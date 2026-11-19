import AppKit
import ClaudeKit

/// Hands chats over to Claude desktop through the links it answers. Saving keeps the chat where it is, while opening brings Claude desktop forward on the session.
enum ClaudeDesktop {
    private static let bundleID = "com.anthropic.claudefordesktop"
    private static let transcriptCheckInterval = Duration.milliseconds(200)
    private static let transcriptWaitChecks = 50
    private static let comingForwardCheckInterval = Duration.milliseconds(100)
    private static let comingForwardWaitChecks = 50

    /// Saves a chat into Claude desktop's Code sessions. A chat with nothing sent yet has no session for Claude desktop to take, and one Claude desktop already has is left alone, since taking it again fails. Claude desktop comes forward as it takes the chat, even though its link is opened in the background, so the search bar is held open meanwhile and takes the keyboard back after, and Claude desktop is hidden again when it was not showing before.
    static func save(_ sessionID: UUID) {
        guard ClaudeSessionFiles.transcript(of: sessionID) != nil, DesktopSessionFiles.session(running: sessionID) == nil else { return }
        let wasShowing = runningApp.map { !$0.isHidden } ?? false
        open(DesktopLinks.resume(sessionID), bringingForward: false)
        Task { await SearchBar.shared.holdOpen { await sendBack(hiding: !wasShowing) } }
    }

    private static func sendBack(hiding: Bool) async {
        for _ in 0..<comingForwardWaitChecks {
            if let app = runningApp, app.isActive {
                if hiding { app.hide() }
                return
            }
            try? await Task.sleep(for: comingForwardCheckInterval)
        }
    }

    private static var runningApp: NSRunningApplication? {
        NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first
    }

    /// Opens a chat's session in Claude desktop. A session Claude desktop already has is opened by its own id. Any other is saved into Claude desktop, which also opens it, once Claude Code has written its transcript, which a chat whose first prompt was only just sent may not have done yet.
    static func open(_ sessionID: UUID) async {
        if let session = DesktopSessionFiles.session(running: sessionID) {
            return open(DesktopLinks.open(desktopID: session.desktopID), bringingForward: true)
        }
        guard await transcriptAppears(for: sessionID) else { return NSSound.beep() }
        open(DesktopLinks.resume(sessionID), bringingForward: true)
    }

    private static func transcriptAppears(for sessionID: UUID) async -> Bool {
        for _ in 0..<transcriptWaitChecks {
            if ClaudeSessionFiles.transcript(of: sessionID) != nil { return true }
            try? await Task.sleep(for: transcriptCheckInterval)
        }
        return false
    }

    private static func open(_ link: URL, bringingForward: Bool) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = bringingForward
        NSWorkspace.shared.open(link, configuration: configuration)
    }
}
