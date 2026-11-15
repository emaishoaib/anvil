import Testing
@testable import CleanerKit

struct HelperBundleIDsTests {
    @Test func aHelperStartingWithTheAppsTeamIDBelongsToTheApp() throws {
        let library = try TemporaryLibrary()
        let appURL = try library.addApp(named: "Example", bundleID: "com.acme.example", helpers: [
            "Library/LoginItems/Browser Helper.app": "ABCDE12345.com.acme.browser-helper",
            "Library/LoginItems/Stranger.app": "FGHIJ67890.com.stranger.helper",
        ])
        let app = AppIdentity(bundleID: "com.acme.example", name: "Example")
        let helpers = HelperBundleIDs.of(app, nestedBundles: NestedBundles.urls(inAppAt: appURL), teamID: "ABCDE12345", otherAppURLs: [])
        #expect(helpers == ["abcde12345.com.acme.browser-helper"])
    }
}
