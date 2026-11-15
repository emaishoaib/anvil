import Foundation

/// The app groups an app and the bundles inside it share files through, read from their code signatures, such as `group.com.example.shared` or `ABCDE12345.com.example`. The Library keeps a group's files under the group's name, so those files belong to the app too.
///
/// A group that another installed app also uses is left out, because its files may belong to that app. A group exists so that two programs can share files, so a group only one bundle inside the app lists is shared with a program outside it, such as another app from the same developer that is not installed. Those lone groups are kept apart, because their files may belong to that program. Groups come back in lowercase.
struct AppGroups: Equatable {
    static let none = AppGroups(sharedWithinApp: [], lone: [])

    let sharedWithinApp: Set<String>
    let lone: Set<String>

    static func of(bundles: [URL], otherAppURLs: [URL], signature: (URL) -> CodeSignature = CodeSignature.init(bundleAt:)) -> AppGroups {
        let listsByBundle = bundles.map { signature($0).appGroups }
        let own = listsByBundle.reduce(into: Set<String>()) { $0.formUnion($1) }
        guard !own.isEmpty else { return .none }
        let usedByOtherApps = otherAppURLs.reduce(into: Set<String>()) { $0.formUnion(signature($1).appGroups) }
        let groups = own.subtracting(usedByOtherApps)
        let lone = groups.filter { group in listsByBundle.count { $0.contains(group) } == 1 }
        return AppGroups(sharedWithinApp: groups.subtracting(lone), lone: lone)
    }
}
