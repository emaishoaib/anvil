import Testing
@testable import LauncherKit

struct QuickLinkActionTests {
    @Test func noFilterListsEveryAction() {
        #expect(QuickLinkAction.matching(" ", appName: "Safari") == QuickLinkAction.allCases)
    }

    @Test func typingDelLeavesOnlyDelete() {
        #expect(QuickLinkAction.matching("del", appName: "Safari") == [.delete])
    }

    @Test func typingCopyLeavesBothCopyActions() {
        #expect(QuickLinkAction.matching("copy", appName: "Safari") == [.copyName, .copyLink])
    }

    @Test func openingIsNamedAfterTheApp() {
        #expect(QuickLinkAction.open.name(openingIn: "Google Chrome") == "Open in Google Chrome")
        #expect(QuickLinkAction.matching("chrome", appName: "Google Chrome") == [.open])
    }

    @Test func openingWithoutAnAppHasAPlainName() {
        #expect(QuickLinkAction.open.name(openingIn: nil) == "Open Quick Link")
    }
}
