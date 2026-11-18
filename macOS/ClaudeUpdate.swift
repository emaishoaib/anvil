import Foundation
import Observation

/// Bringing Claude Code up to date once a chat finds it too old for the options Anvil starts it with. Updating runs Claude Code's own updater and ends when the updater does, after which the prompt can be sent again. An update that fails can be tried again, and one still running can be stopped. Sending the next prompt puts this back to not needed.
@Observable final class ClaudeUpdate {
    enum State {
        case notNeeded
        case needed
        case updating
        case updated
        case failed
    }

    private(set) var state = State.notNeeded
    @ObservationIgnored private var updater: Process?

    func need() {
        guard updater == nil else { return }
        state = .needed
    }

    func update() {
        guard updater == nil, let updater = ClaudeCommand.process(["update"]) else { return }
        self.updater = updater
        state = .updating
        Task {
            let output = await updater.output()
            guard self.updater === updater else { return }
            self.updater = nil
            state = output != nil && updater.terminationStatus == 0 ? .updated : .failed
        }
    }

    func cancel() {
        updater?.terminate()
        updater = nil
        state = .needed
    }

    func forget() {
        guard updater == nil else { return }
        state = .notNeeded
    }
}
