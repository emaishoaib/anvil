import Foundation

enum LidSleep {
    static func setDisabled(_ isDisabled: Bool) async -> Bool {
        let prompt = isDisabled
            ? "Anvil needs your password to keep the Mac awake with the lid closed."
            : "Anvil needs your password to let the Mac sleep with the lid closed again."
        let script = "do shell script \"/usr/bin/pmset -a disablesleep \(isDisabled ? 1 : 0)\" with prompt \"\(prompt)\" with administrator privileges"
        return await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(filePath: "/usr/bin/osascript")
            process.arguments = ["-e", script]
            process.terminationHandler = { continuation.resume(returning: $0.terminationStatus == 0) }
            do {
                try process.run()
            } catch {
                continuation.resume(returning: false)
            }
        }
    }
}
