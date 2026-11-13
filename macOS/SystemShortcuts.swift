import Carbon.HIToolbox

enum SystemShortcuts {
    static func enabled() -> Set<KeyCombo> {
        var hotKeys: Unmanaged<CFArray>?
        guard CopySymbolicHotKeys(&hotKeys) == noErr, let list = hotKeys?.takeRetainedValue() as? [[String: Any]] else { return [] }
        return Set(list.compactMap { hotKey in
            guard hotKey["kHISymbolicHotKeyEnabled"] as? Bool == true,
                  let keyCode = hotKey["kHISymbolicHotKeyCode"] as? Int,
                  let carbonMask = hotKey["kHISymbolicHotKeyModifiers"] as? Int
            else { return nil }
            return KeyCombo(keyCode: keyCode, modifiers: KeyModifiers(carbonMask: carbonMask))
        })
    }
}
