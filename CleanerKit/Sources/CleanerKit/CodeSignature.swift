import Foundation
import Security

/// What a bundle's code signature says about it: the team ID of the developer who signed it, and the app groups it shares files through, such as `group.com.example.shared`. App groups come back in lowercase. An unsigned bundle has neither.
struct CodeSignature {
    private static let appGroupsKey = "com.apple.security.application-groups"

    let teamID: String?
    let appGroups: Set<String>

    init(teamID: String?, appGroups: Set<String>) {
        self.teamID = teamID
        self.appGroups = appGroups
    }

    init(bundleAt url: URL) {
        let info = Self.signingInformation(of: url)
        let entitlements = info[kSecCodeInfoEntitlementsDict as String] as? [String: Any]
        let appGroups = entitlements?[Self.appGroupsKey] as? [String] ?? []
        self.init(teamID: info[kSecCodeInfoTeamIdentifier as String] as? String, appGroups: Set(appGroups.map { $0.lowercased() }))
    }

    private static func signingInformation(of url: URL) -> [String: Any] {
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess, let code else { return [:] }
        var info: CFDictionary?
        guard SecCodeCopySigningInformation(code, SecCSFlags(rawValue: kSecCSSigningInformation), &info) == errSecSuccess else { return [:] }
        return info as? [String: Any] ?? [:]
    }
}
