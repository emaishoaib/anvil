import Foundation

/// The app groups an app and the bundles inside it share files through, read from their code signatures, such as `group.com.example.shared` or `ABCDE12345.com.example`. The Library keeps a group's files under the group's name, so those files belong to the app too.
///
/// A group that another installed app also uses is left out, because its files may belong to that app. Groups come back in lowercase.
enum AppGroups {
    static func of(bundles: [URL], otherAppURLs: [URL], signature: (URL) -> CodeSignature = CodeSignature.init(bundleAt:)) -> Set<String> {
        let own = bundles.reduce(into: Set<String>()) { $0.formUnion(signature($1).appGroups) }
        guard !own.isEmpty else { return [] }
        let shared = otherAppURLs.reduce(into: Set<String>()) { $0.formUnion(signature($1).appGroups) }
        return own.subtracting(shared)
    }
}
