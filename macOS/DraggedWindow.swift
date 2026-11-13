import AppKit

struct DraggedWindow {
    let element: AXUIElement
    let id: CGWindowID
    var frameBeforeSnap: CGRect
    let pointerAtPress: CGPoint

    var liveFrame: CGRect? {
        WindowUnderPointer.liveFrame(of: id)
    }

    init?(under appKitPoint: NSPoint, pointer: CGPoint) {
        guard let window = WindowUnderPointer(at: appKitPoint) else { return nil }
        element = window.element
        id = window.id
        frameBeforeSnap = window.frame
        pointerAtPress = pointer
    }
}
