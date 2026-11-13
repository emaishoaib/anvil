import AppKit

final class TitleBarClicks {
    static let shared = TitleBarClicks()

    private static let titleBarRoles: Set<String> = [kAXWindowRole, kAXToolbarRole, kAXGroupRole, kAXStaticTextRole, kAXImageRole]

    func start() {
        _ = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { event in
            guard event.clickCount == 2 else { return }
            MainActor.assumeIsolated { TitleBarClicks.shared.doubleClicked() }
        }
    }

    private func doubleClicked() {
        let pointer = CGEvent(source: nil)?.location ?? .zero
        guard Tool.windows.isOn, SnappingSettings.maximizesOnTitleBarDoubleClick,
              let window = WindowUnderPointer(at: NSEvent.mouseLocation),
              let titleBarHeight = window.element.titleBarHeight,
              pointer.y - window.frame.minY <= titleBarHeight,
              let role = window.app.role(at: pointer), Self.titleBarRoles.contains(role)
        else { return }
        Snapping.shared.toggleMaximize(window)
    }
}
