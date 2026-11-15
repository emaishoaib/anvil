import SwiftUI

/// The footer status item for one AirPod's battery, shown as that side's earbud. It turns orange when the battery runs low.
struct EarbudBatteryStatus: View {
    private static let lowPercentage = 20

    let earbud: EarbudBattery

    var body: some View {
        StatusItem(symbol: symbol, title: "\(earbud.percentage)%", emphasis: earbud.percentage <= Self.lowPercentage ? .warning : .quiet)
            .help("\(earbud.deviceName), \(sideName): \(earbud.percentage)%")
    }

    private var symbol: String {
        switch earbud.side {
        case .left: "airpod.left"
        case .right: "airpod.right"
        }
    }

    private var sideName: String {
        switch earbud.side {
        case .left: "left"
        case .right: "right"
        }
    }
}
