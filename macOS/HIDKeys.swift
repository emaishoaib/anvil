enum HIDKeys {
    static let all: [(usage: Int, name: String)] = letters + digits + symbols + specials + modifiers

    static func name(for usage: Int) -> String {
        all.first { $0.usage == usage }?.name ?? "Key \(usage)"
    }

    private static let letters = (0..<26).map { (0x04 + $0, String(UnicodeScalar(UInt8(65 + $0)))) }

    private static let digits = (1...9).map { (0x1D + $0, "\($0)") } + [(0x27, "0")]

    private static let symbols = [
        (0x35, "` (left of Z on ISO keyboards)"), (0x64, "§ (left of 1 on ISO keyboards)"),
        (0x2D, "-"), (0x2E, "="), (0x2F, "["), (0x30, "]"), (0x31, "\\"),
        (0x33, ";"), (0x34, "'"), (0x36, ","), (0x37, "."), (0x38, "/"),
    ]

    private static let specials = [
        (0x28, "Return"), (0x29, "Escape"), (0x2A, "Delete"), (0x2B, "Tab"), (0x2C, "Space"), (0x39, "Caps Lock"),
    ]

    private static let modifiers = [
        (0xE0, "Left Control"), (0xE1, "Left Shift"), (0xE2, "Left Option"), (0xE3, "Left Command"),
        (0xE4, "Right Control"), (0xE5, "Right Shift"), (0xE6, "Right Option"), (0xE7, "Right Command"),
    ]
}
