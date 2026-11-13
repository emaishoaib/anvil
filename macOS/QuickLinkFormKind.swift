enum QuickLinkFormKind {
    case create, edit, duplicate

    var title: String {
        switch self {
        case .create: "Create Quick Link"
        case .edit: "Edit Quick Link"
        case .duplicate: "Duplicate Quick Link"
        }
    }

    var saveTitle: String {
        self == .edit ? "Update Quick Link" : "Create Quick Link"
    }
}
