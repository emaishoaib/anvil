import Foundation
import LauncherKit
import Observation

@Observable final class QuickLinkLibrary {
    static let shared = QuickLinkLibrary()

    private static let key = "launcher.quickLinks"

    private(set) var quickLinks: QuickLinks

    private init() {
        let saved = UserDefaults.standard.data(forKey: Self.key).flatMap { try? JSONDecoder().decode([QuickLink].self, from: $0) }
        quickLinks = QuickLinks(saved ?? [])
    }

    var links: [QuickLink] { quickLinks.links }

    func save(_ link: QuickLink) {
        quickLinks.save(link)
        persist()
    }

    func add(_ incoming: [QuickLink]) -> (added: Int, skipped: Int) {
        let result = quickLinks.add(incoming)
        persist()
        return result
    }

    func delete(_ link: QuickLink) {
        quickLinks.delete(link)
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(try? JSONEncoder().encode(quickLinks.links), forKey: Self.key)
    }
}
