import Testing
@testable import CleanerKit

struct WalkMatchTests {
    private let example = WalkMatch(app: AppIdentity(bundleID: "com.acme.example", name: "Example"))

    @Test func aNameStartingWithTheBundleIDIsFound() {
        #expect(example.matches("com.acme.example.plist"))
        #expect(example.matches("com.acme.example.1.69.0.plist"))
    }

    @Test func theBundleIDInsideALongerNameIsFound() {
        #expect(example.matches("com.apple.WebKit.GPU+com.acme.example"))
    }

    @Test func aBundleIDThatOnlySharesItsFirstLettersIsNotFound() {
        #expect(!example.matches("com.acme.examples"))
    }

    @Test func helperBundleIDsAndAppGroupsAreFound() {
        let match = WalkMatch(app: AppIdentity(bundleID: "com.acme.example", name: "Example", helperBundleIDs: ["com.acme.example-helper"], appGroups: ["group.com.acme.shared"]))
        #expect(match.matches("com.acme.example-helper"))
        #expect(match.matches("group.com.acme.shared"))
    }

    @Test func theAppNameAsAWholeWordIsFound() {
        #expect(example.matches("Example"))
        #expect(example.matches("example_br"))
        #expect(example.matches("Example.log"))
        #expect(example.matches("example-updater"))
    }

    @Test func theAppNameInsideALongerWordIsNotFound() {
        #expect(!example.matches("ARExampleQuery.h"))
        #expect(!example.matches("ExampleQuickLinks.o"))
    }

    @Test func anAppNameWithSpacesIsFoundWithOrWithoutThem() {
        let match = WalkMatch(app: AppIdentity(bundleID: "com.acme.notes", name: "Visual Notes"))
        #expect(match.matches("Visual Notes"))
        #expect(match.matches("visual-notes"))
        #expect(match.matches("VisualNotes"))
    }

    @Test func theAppsOtherNamesAreNotUsed() {
        let match = WalkMatch(app: AppIdentity(bundleID: "com.microsoft.VSCode", name: "Visual Studio Code", otherNames: ["Code"]))
        #expect(!match.matches("Code"))
    }

    @Test func anAppNameWithFewerThanThreeLettersIsNotUsed() {
        let match = WalkMatch(app: AppIdentity(bundleID: "com.acme.go", name: "Go"))
        #expect(!match.matches("go"))
        #expect(match.matches("com.acme.go"))
    }

    @Test func applesOwnAppsAreNeverMatched() {
        let match = WalkMatch(app: AppIdentity(bundleID: "com.apple.Notes", name: "Notes"))
        #expect(!match.matches("Notes"))
        #expect(!match.matches("com.apple.Notes"))
    }
}
