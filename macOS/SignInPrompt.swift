import SwiftUI

/// What AI mode shows instead of a chat while Claude Code is signed out: what is wrong and the key that fixes it. While the sign-in waits on the browser, it says so and how to stop it.
struct SignInPrompt: View {
    let isSigningIn: Bool

    var body: some View {
        VStack(spacing: 8) {
            if isSigningIn {
                AnvilLoader()
                Text("Finish signing in in your browser")
                    .font(.headline)
                Text("Anvil carries on once Claude Code is signed in.")
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Claude Code isn't signed in")
                    .font(.headline)
                Text("Press Return to sign in with your Claude account in the browser.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
