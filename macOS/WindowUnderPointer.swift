import AppKit

struct WindowUnderPointer {
    private static let normalWindowLayer = 0
    private static let frameAnswerTimeout: Float = 0.25

    let app: AXUIElement
    let element: AXUIElement
    let id: CGWindowID
    let frame: CGRect

    init?(at appKitPoint: NSPoint) {
        let id = CGWindowID(NSWindow.windowNumber(at: appKitPoint, belowWindowWithWindowNumber: 0))
        guard id != 0,
              let info = Self.serverInfo(of: id),
              let pid = info[kCGWindowOwnerPID as String] as? pid_t, pid != getpid(),
              info[kCGWindowLayer as String] as? Int == Self.normalWindowLayer,
              let frame = Self.bounds(info)
        else { return nil }
        let app = AXUIElement.appWithShortTimeout(pid)
        guard let element = app.windows?.first(where: { $0.windowID == id }) else { return nil }
        AXUIElementSetMessagingTimeout(element, Self.frameAnswerTimeout)
        self.app = app
        self.element = element
        self.id = id
        self.frame = frame
    }

    static func liveFrame(of id: CGWindowID) -> CGRect? {
        serverInfo(of: id).flatMap(bounds)
    }

    private static func serverInfo(of id: CGWindowID) -> [String: Any]? {
        (CGWindowListCopyWindowInfo(.optionIncludingWindow, id) as? [[String: Any]])?.first
    }

    private static func bounds(_ info: [String: Any]) -> CGRect? {
        (info[kCGWindowBounds as String] as? [String: Any]).flatMap { CGRect(dictionaryRepresentation: $0 as CFDictionary) }
    }
}
