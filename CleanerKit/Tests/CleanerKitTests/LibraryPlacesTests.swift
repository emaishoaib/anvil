import Testing
@testable import CleanerKit

struct LibraryPlacesTests {
    @Test func aFolderInTheLibraryItselfNamedAfterTheAppIsFoundAndStartsUnticked() throws {
        let library = try TemporaryLibrary("TeXShop/Templates/article.tex")
        let app = try library.addApp(named: "TeXShop", bundleID: "com.acme.texshop")
        let items = RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [])
        #expect(items.dropFirst().map { library.relativePath(of: $0.url) } == ["TeXShop"])
        #expect(items.map(\.startsTicked) == [true, false])
    }

    @Test func theFoldersMacOSMakesInTheLibraryNeverMatch() throws {
        let library = try TemporaryLibrary("Fonts/Example.ttf", "Keychains/login.keychain-db")
        #expect(library.leftoverPaths(of: "com.acme.fonts", named: "Fonts").isEmpty)
        #expect(library.leftoverPaths(of: "com.acme.keychains", named: "Keychains").isEmpty)
    }

    @Test func aVendorsFolderInTheLibraryItselfIsLeftAlone() throws {
        let library = try TemporaryLibrary("Acme/Updater/state")
        #expect(library.leftoverPaths(of: "com.acme.example").isEmpty)
    }

    @Test func cookiesNamedAfterTheBundleIDAreFound() throws {
        let library = try TemporaryLibrary("Cookies/com.acme.example.binarycookies", "Cookies/com.other.app.binarycookies")
        #expect(library.leftoverPaths(of: "com.acme.example") == ["Cookies/com.acme.example.binarycookies"])
    }

    @Test func anUpdaterCacheNamedAfterTheAppIsFound() throws {
        let library = try TemporaryLibrary("Application Support/Caches/Example/update.zip", "Application Support/Caches/Other/update.zip")
        #expect(library.leftoverPaths(of: "com.acme.example") == ["Application Support/Caches/Example"])
    }
}
