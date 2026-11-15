import SwiftUI

/// The small status items beside the Anvil button in the search bar's footer, such as whether Keep Awake is holding the Mac awake and how full each Logitech mouse and keyboard battery is. The row and its divider only show when at least one item has something to show.
struct StatusRow: View {
    var body: some View {
        let showsKeepAwake = Tool.keepAwake.isOn
        let batteries = LogitechBatteryStatus.all()
        if showsKeepAwake || !batteries.isEmpty {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(.primary.opacity(0.15))
                    .frame(width: 1, height: 16)
                if showsKeepAwake {
                    KeepAwakeStatus(state: KeepAwake.shared.state)
                }
                ForEach(batteries) { $0 }
            }
        }
    }
}

private struct KeepAwakeStatus: View {
    let state: KeepAwake.State

    var body: some View {
        StatusItem(symbol: symbol, title: title, emphasis: isAwake ? .active : .quiet)
            .help(help)
    }

    private var isAwake: Bool {
        switch state {
        case .off: false
        case .awake: true
        }
    }

    private var symbol: String {
        isAwake ? "cup.and.heat.waves" : "cup.and.saucer"
    }

    private var title: String {
        switch state {
        case .off: "Off"
        case .awake(_, let withLidClosed): withLidClosed ? "Awake, lid closed" : "Awake"
        }
    }

    private var help: String {
        switch state {
        case .off: "Keep Awake is off, so your Mac sleeps as usual"
        case .awake(_, let withLidClosed): withLidClosed ? "Keep Awake is keeping your Mac awake, even with the lid closed" : "Keep Awake is keeping your Mac awake"
        }
    }
}
