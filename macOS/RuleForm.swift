import SwiftUI

/// The rule editor inside the search bar: when the rule runs, in which apps, and what it does. A small grouped form, as it holds only a handful of fields. Choosing apps opens its panel through the search bar, so the bar stays open behind it.
struct RuleForm: View {
    private static let height: CGFloat = 420

    @Binding var draft: RuleDraft
    let group: RuleGroup

    var body: some View {
        Form {
            Section("When") {
                RuleTriggerFields(draft: $draft, kinds: group.triggerKinds)
            }
            Section("In") {
                RuleAppsPicker(apps: $draft.apps) { SearchBar.shared.presentModal(InstalledAppNames.chooseApps) }
            }
            Section("Do") {
                RuleActionFields(draft: $draft)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .frame(height: Self.height)
    }
}
