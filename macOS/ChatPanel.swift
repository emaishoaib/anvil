import AppKit

/// The window a popped-out chat lives in. Like the search bar it floats over other apps without making Anvil the active app, shows on every Space, and takes the keyboard when clicked, but it sits below the search bar and can be moved and resized. Keys go to the chat first, and whatever the chat does not use goes on to the window as usual.
final class ChatPanel: NSPanel {
    private static let minimumSize = NSSize(width: 420, height: 320)

    var handleKey: (NSEvent) -> Bool = { _ in false }

    convenience init(frame: NSRect) {
        self.init(contentRect: frame, styleMask: [.borderless, .resizable, .nonactivatingPanel], backing: .buffered, defer: true)
        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        minSize = Self.minimumSize

        let background = NSVisualEffectView()
        background.material = .popover
        background.state = .active
        background.wantsLayer = true
        background.roundCorners(radius: SearchStyle.barCornerRadius)
        contentView = background
    }

    override var canBecomeKey: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown, handleKey(event) else { return super.sendEvent(event) }
    }

    override func becomeKey() {
        super.becomeKey()
        RuleKeys.shared.searchBarFocusChanged(true)
    }

    override func resignKey() {
        super.resignKey()
        RuleKeys.shared.searchBarFocusChanged(false)
    }
}
