import AppKit

nonisolated extension AXUIElement {
    var focusedWindow: AXUIElement? {
        guard let value = copyValue(kAXFocusedWindowAttribute), CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }
        return (value as! AXUIElement)
    }

    var frame: CGRect? {
        var position = CGPoint.zero
        var size = CGSize.zero
        guard read(kAXPositionAttribute, .cgPoint, into: &position), read(kAXSizeAttribute, .cgSize, into: &size) else { return nil }
        return CGRect(origin: position, size: size)
    }

    func move(to frame: CGRect) {
        var size = frame.size
        var position = frame.origin
        write(kAXSizeAttribute, .cgSize, from: &size)
        write(kAXPositionAttribute, .cgPoint, from: &position)
        write(kAXSizeAttribute, .cgSize, from: &size)
    }

    private func copyValue(_ attribute: String) -> CFTypeRef? {
        var value: CFTypeRef?
        return AXUIElementCopyAttributeValue(self, attribute as CFString, &value) == .success ? value : nil
    }

    private func read<Value: BitwiseCopyable>(_ attribute: String, _ type: AXValueType, into result: inout Value) -> Bool {
        guard let value = copyValue(attribute), CFGetTypeID(value) == AXValueGetTypeID() else { return false }
        return AXValueGetValue(value as! AXValue, type, &result)
    }

    private func write<Value: BitwiseCopyable>(_ attribute: String, _ type: AXValueType, from input: inout Value) {
        guard let value = AXValueCreate(type, &input) else { return }
        AXUIElementSetAttributeValue(self, attribute as CFString, value)
    }
}
