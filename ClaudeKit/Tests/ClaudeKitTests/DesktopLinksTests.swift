import Foundation
import Testing
@testable import ClaudeKit

struct DesktopLinksTests {
    @Test func resumingASessionNamesItInLowercase() {
        let sessionID = UUID(uuidString: "564A392C-6B37-4786-9D80-0A5BDE99A545")!
        #expect(DesktopLinks.resume(sessionID).absoluteString == "claude://resume?session=564a392c-6b37-4786-9d80-0a5bde99a545")
    }

    @Test func openingASessionNamesItByClaudeDesktopsOwnID() {
        #expect(DesktopLinks.open(desktopID: "local_a02fd0ad-4c4e-4974-a9c3-6fbe5361a280").absoluteString == "claude://code/continue?session=local_a02fd0ad-4c4e-4974-a9c3-6fbe5361a280")
    }
}
