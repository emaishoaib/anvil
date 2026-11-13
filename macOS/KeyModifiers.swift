import AppKit
import Carbon.HIToolbox

nonisolated struct KeyModifiers: OptionSet, Hashable {
    let rawValue: Int

    static let control = KeyModifiers(rawValue: 1 << 0)
    static let option = KeyModifiers(rawValue: 1 << 1)
    static let shift = KeyModifiers(rawValue: 1 << 2)
    static let command = KeyModifiers(rawValue: 1 << 3)

    private static let all: [(modifier: KeyModifiers, flag: CGEventFlags, eventFlag: NSEvent.ModifierFlags, carbonMask: Int, symbol: String)] = [
        (.control, .maskControl, .control, controlKey, "⌃"),
        (.option, .maskAlternate, .option, optionKey, "⌥"),
        (.shift, .maskShift, .shift, shiftKey, "⇧"),
        (.command, .maskCommand, .command, cmdKey, "⌘"),
    ]

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(flags: CGEventFlags) {
        self.init(Self.all.filter { flags.contains($0.flag) }.map(\.modifier))
    }

    init(eventFlags: NSEvent.ModifierFlags) {
        self.init(Self.all.filter { eventFlags.contains($0.eventFlag) }.map(\.modifier))
    }

    init(carbonMask: Int) {
        self.init(Self.all.filter { carbonMask & $0.carbonMask != 0 }.map(\.modifier))
    }

    var flags: CGEventFlags {
        CGEventFlags(Self.all.filter { contains($0.modifier) }.map(\.flag))
    }

    var symbols: String {
        orderedSymbols.joined()
    }

    var orderedSymbols: [String] {
        Self.all.filter { contains($0.modifier) }.map(\.symbol)
    }
}
