import SwiftUI

struct GeneralPage: View {
    var body: some View {
        Form {
            SearchBarShortcutSection()
            SettingsFolderSection()
        }
        .formStyle(.grouped)
    }
}
