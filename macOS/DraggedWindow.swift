import AppKit

struct DraggedWindow {
    private static let normalWindowLayer = 0
    private static let frameAnswerTimeout: Float = 0.25

    let element: AXUIElement
    let id: CGWindowID
    let frameBeforeDrag: CGRect
    let pointerAtPress: CGPoint

    var liveFrame: CGRect? {
        Self.serverInfo(of: id).flatMap(Self.bounds)
    }

    init?(under appKitPoint: NSPoint, pointer: CGPoint) {
        let id = CGWindowID(NSWindow.windowNumber(at: appKitPoint, belowWindowWithWindowNumber: 0))
        guard id != 0,
              let info = Self.serverInfo(of: id),
              let pid = info[kCGWindowOwnerPID as String] as? pid_t, pid != getpid(),
              info[kCGWindowLayer as String] as? Int == Self.normalWindowLayer,
              let frame = Self.bounds(info),
              let element = AXUIElement.appWithShortTimeout(pid).windows?.first(where: { $0.windowID == id })
        else { return nil }
        AXUIElementSetMessagingTimeout(element, Self.frameAnswerTimeout)
        self.element = element
        self.id = id
        frameBeforeDrag = frame
        pointerAtPress = pointer
    }

    private static func serverInfo(of id: CGWindowID) -> [String: Any]? {
        (CGWindowListCopyWindowInfo(.optionIncludingWindow, id) as? [[String: Any]])?.first
    }

    private static func bounds(_ info: [String: Any]) -> CGRect? {
        (info[kCGWindowBounds as String] as? [String: Any]).flatMap { CGRect(dictionaryRepresentation: $0 as CFDictionary) }
    }
}
