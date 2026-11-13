import Foundation
import LauncherKit

struct LinkArguments {
    private(set) var link: QuickLink?
    private(set) var values: [String] = []

    var placeholders: [String] { link?.placeholders ?? [] }

    var firstBlank: Int? {
        values.firstIndex { $0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func value(at index: Int) -> String {
        values.indices.contains(index) ? values[index] : ""
    }

    mutating func set(_ value: String, at index: Int) {
        guard values.indices.contains(index) else { return }
        values[index] = value
    }

    mutating func show(for link: QuickLink?) -> Bool {
        guard link?.id != self.link?.id else { return false }
        self.link = link
        values = Array(repeating: "", count: link?.placeholders.count ?? 0)
        return true
    }
}
