import AppKit

enum MenuItems {
    static func choose(_ path: [String]) {
        guard let pid = NSWorkspace.shared.frontmostPID,
              var current = AXUIElement.appWithShortTimeout(pid).menuElement(kAXMenuBarAttribute)
        else { return }
        for title in path {
            let items = current.menuChildren.flatMap { $0.menuRole == kAXMenuRole ? $0.menuChildren : [$0] }
            guard let item = items.first(where: { $0.menuTitle == title }) else { return }
            current = item
        }
        AXUIElementPerformAction(current, kAXPressAction as CFString)
    }
}

private extension AXUIElement {
    var menuChildren: [AXUIElement] {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(self, kAXChildrenAttribute as CFString, &value) == .success else { return [] }
        return value as? [AXUIElement] ?? []
    }

    var menuTitle: String? { menuText(kAXTitleAttribute) }

    var menuRole: String? { menuText(kAXRoleAttribute) }

    func menuElement(_ attribute: String) -> AXUIElement? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(self, attribute as CFString, &value) == .success,
              let value, CFGetTypeID(value) == AXUIElementGetTypeID()
        else { return nil }
        return (value as! AXUIElement)
    }

    private func menuText(_ attribute: String) -> String? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(self, attribute as CFString, &value) == .success else { return nil }
        return value as? String
    }
}
