import AppKit

final class SearchPanel: NSPanel {
    convenience init() {
        self.init(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        level = .popUpMenu
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let background = NSVisualEffectView()
        background.material = .popover
        background.state = .active
        background.wantsLayer = true
        background.roundCorners(radius: SearchStyle.barCornerRadius)
        contentView = background
    }

    override var canBecomeKey: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown, SearchBar.shared.handleKey(Int(event.keyCode), modifiers: event.modifierFlags) else { return super.sendEvent(event) }
    }

    override func becomeKey() {
        super.becomeKey()
        RuleKeys.shared.searchBarFocusChanged(true)
        SearchBar.shared.tookFocus()
    }

    override func resignKey() {
        super.resignKey()
        RuleKeys.shared.searchBarFocusChanged(false)
        SearchBar.shared.lostFocus()
    }
}
