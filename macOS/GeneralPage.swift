import SwiftUI

struct GeneralPage: View {
    var body: some View {
        Form {
            SettingsFolderSection()
        }
        .formStyle(.grouped)
    }
}
