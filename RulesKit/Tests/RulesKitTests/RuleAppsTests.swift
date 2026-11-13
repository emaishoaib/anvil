import Foundation
import Testing
@testable import RulesKit

struct RuleAppsTests {
    let apps = RuleApps.only(bundleIDs: ["com.microsoft.VSCodeInsiders", "com.microsoft.VSCode", "md.obsidian"])

    @Test func chosenAppsAreAlwaysWrittenInAlphabeticalOrder() throws {
        let json = String(decoding: try JSONEncoder().encode(apps), as: UTF8.self)
        #expect(json == #"{"only":{"bundleIDs":["com.microsoft.VSCode","com.microsoft.VSCodeInsiders","md.obsidian"]}}"#)
    }

    @Test func chosenAppsComeBackUnchangedFromJSON() throws {
        #expect(try JSONDecoder().decode(RuleApps.self, from: JSONEncoder().encode(apps)) == apps)
    }

    @Test func allAppsComeBackUnchangedFromJSON() throws {
        let json = String(decoding: try JSONEncoder().encode(RuleApps.all), as: UTF8.self)
        #expect(json == #"{"all":{}}"#)
        #expect(try JSONDecoder().decode(RuleApps.self, from: Data(json.utf8)) == .all)
    }
}
