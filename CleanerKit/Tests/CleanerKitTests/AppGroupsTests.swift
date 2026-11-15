import Foundation
import Testing
@testable import CleanerKit

struct AppGroupsTests {
    let app = URL(filePath: "/Applications/Example.app")
    let helper = URL(filePath: "/Applications/Example.app/Contents/PlugIns/Share.appex")
    let otherApp = URL(filePath: "/Applications/Other.app")

    func signature(withGroups groups: [URL: Set<String>]) -> (URL) -> CodeSignature {
        { CodeSignature(teamID: nil, appGroups: groups[$0] ?? []) }
    }

    @Test func aGroupSeveralBundlesInsideTheAppListIsSharedWithinIt() {
        let signature = signature(withGroups: [app: ["group.com.acme.shared"], helper: ["group.com.acme.shared"]])
        #expect(AppGroups.of(bundles: [app, helper], otherAppURLs: [], signature: signature) == AppGroups(sharedWithinApp: ["group.com.acme.shared"], lone: []))
    }

    @Test func aGroupOnlyOneBundleListsIsLone() {
        let signature = signature(withGroups: [app: ["group.com.acme.shared", "group.com.acme.sibling"], helper: ["group.com.acme.shared", "abcde12345.com.acme"]])
        let groups = AppGroups.of(bundles: [app, helper], otherAppURLs: [], signature: signature)
        #expect(groups == AppGroups(sharedWithinApp: ["group.com.acme.shared"], lone: ["group.com.acme.sibling", "abcde12345.com.acme"]))
    }

    @Test func aGroupAnotherInstalledAppUsesIsLeftOut() {
        let signature = signature(withGroups: [app: ["group.com.acme.shared", "group.com.acme.example"], helper: ["group.com.acme.shared", "group.com.acme.example"], otherApp: ["group.com.acme.shared"]])
        #expect(AppGroups.of(bundles: [app, helper], otherAppURLs: [otherApp], signature: signature) == AppGroups(sharedWithinApp: ["group.com.acme.example"], lone: []))
    }

    @Test func anUnsignedAppHasNoGroups() throws {
        let library = try TemporaryLibrary()
        let unsigned = try library.addApp(named: "Example", bundleID: "com.acme.example")
        #expect(AppGroups.of(bundles: [unsigned], otherAppURLs: []) == .none)
    }
}
