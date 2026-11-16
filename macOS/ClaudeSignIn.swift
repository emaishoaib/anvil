import ClaudeKit
import Foundation
import Observation

/// Whether Claude Code is signed in, and signing it in when it is not. Signing in runs Claude Code's own sign-in, which opens the browser and ends once the sign-in is approved there, and then the status is checked again. Until the first check comes back the status is unknown, and a chat can start anyway.
@Observable final class ClaudeSignIn {
    enum State {
        case unknown
        case signedIn
        case signedOut
        case signingIn
    }

    private(set) var state = State.unknown
    @ObservationIgnored private var login: Process?

    func check() {
        guard let status = ClaudeCommand.process(["auth", "status", "--json"]) else { return }
        Task {
            let output = await status.output()
            guard login == nil else { return }
            state = switch output.flatMap(ClaudeAuthStatus.isSignedIn) {
            case true?: .signedIn
            case false?: .signedOut
            case nil: .unknown
            }
        }
    }

    func signIn() {
        guard login == nil, let login = ClaudeCommand.process(["auth", "login", "--claudeai"]) else { return }
        self.login = login
        state = .signingIn
        Task {
            _ = await login.output()
            guard self.login === login else { return }
            self.login = nil
            check()
        }
    }

    func cancel() {
        login?.terminate()
        login = nil
        state = .signedOut
    }
}
