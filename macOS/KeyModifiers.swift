import Carbon.HIToolbox
import CoreGraphics

nonisolated struct KeyModifiers: OptionSet, Hashable {
    let rawValue: Int

    static let control = KeyModifiers(rawValue: 1 << 0)
    static let option = KeyModifiers(rawValue: 1 << 1)
    static let shift = KeyModifiers(rawValue: 1 << 2)
    static let command = KeyModifiers(rawValue: 1 << 3)

    private static let all: [(modifier: KeyModifiers, flag: CGEventFlags, carbonMask: Int, symbol: String)] = [
        (.control, .maskControl, controlKey, "⌃"),
        (.option, .maskAlternate, optionKey, "⌥"),
        (.shift, .maskShift, shiftKey, "⇧"),
        (.command, .maskCommand, cmdKey, "⌘"),
    ]

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(flags: CGEventFlags) {
        self.init(Self.all.filter { flags.contains($0.flag) }.map(\.modifier))
    }

    init(carbonMask: Int) {
        self.init(Self.all.filter { carbonMask & $0.carbonMask != 0 }.map(\.modifier))
    }

    var symbols: String {
        Self.all.filter { contains($0.modifier) }.map(\.symbol).joined()
    }
}
