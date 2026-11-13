import Foundation
import Testing
@testable import LauncherKit

struct FaviconPageTests {
    let base = URL(string: "https://www.facebook.com/marketplace")!

    func urls(_ html: String) -> [String] {
        FaviconPage.iconURLs(in: html, baseURL: base).map(\.absoluteString)
    }

    @Test func aPageWithNoIconsFallsBackToTheSiteFavicon() {
        #expect(urls("<html></html>") == ["https://www.facebook.com/favicon.ico"])
    }

    @Test func relativeIconsAreResolvedAgainstThePage() {
        #expect(urls(#"<link rel="icon" href="/rsrc/icon.png">"#).first == "https://www.facebook.com/rsrc/icon.png")
    }

    @Test func largerIconsComeFirst() {
        let html = """
        <link rel="icon" href="/small.png" sizes="16x16">
        <link rel="apple-touch-icon" href="/touch.png">
        <LINK REL='shortcut icon' HREF='/big.png' SIZES='192x192'>
        """
        #expect(urls(html) == [
            "https://www.facebook.com/big.png",
            "https://www.facebook.com/touch.png",
            "https://www.facebook.com/small.png",
            "https://www.facebook.com/favicon.ico",
        ])
    }

    @Test func linksThatAreNotIconsAreIgnored() {
        let html = #"<link rel="stylesheet" href="/site.css"><link rel="mask-icon" href="/mask.svg">"#
        #expect(urls(html) == ["https://www.facebook.com/favicon.ico"])
    }

    @Test func escapedAmpersandsInTheAddressAreDecoded() {
        #expect(urls(#"<link rel="icon" href="https://cdn.example.com/icon?v=2&amp;size=64">"#).first == "https://cdn.example.com/icon?v=2&size=64")
    }

    @Test func theSiteFaviconIsNotListedTwice() {
        #expect(urls(#"<link rel="icon" href="/favicon.ico">"#) == ["https://www.facebook.com/favicon.ico"])
    }
}
