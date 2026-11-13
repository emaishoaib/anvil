import RulesKit
import SwiftUI

struct RuleAppsPicker: View {
    @Binding var apps: RuleApps

    var body: some View {
        Picker("Works In", selection: choosesApps) {
            Text("All Apps").tag(false)
            Text("Chosen Apps").tag(true)
        }
        if case .only(let bundleIDs) = apps {
            ForEach(bundleIDs.sorted { InstalledAppNames.name(for: $0) < InstalledAppNames.name(for: $1) }, id: \.self) { bundleID in
                ChosenAppRow(bundleID: bundleID) { apps = .only(bundleIDs: bundleIDs.subtracting([bundleID])) }
            }
            Button("Add App…") { apps = .only(bundleIDs: bundleIDs.union(InstalledAppNames.chooseApps())) }
        }
    }

    private var choosesApps: Binding<Bool> {
        Binding(
            get: { apps.isChosen },
            set: { apps = $0 ? .only(bundleIDs: []) : .all }
        )
    }
}

private struct ChosenAppRow: View {
    let bundleID: String
    let remove: () -> Void

    var body: some View {
        HStack {
            if let url = InstalledAppNames.url(for: bundleID) {
                Image(nsImage: url.menuIcon)
            }
            Text(InstalledAppNames.name(for: bundleID))
            Spacer()
            Button("Remove", systemImage: "minus.circle", action: remove)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
        }
    }
}
