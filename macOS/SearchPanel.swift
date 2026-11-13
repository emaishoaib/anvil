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
        background.layer?.cornerRadius = 12
        background.layer?.masksToBounds = true
        contentView = background
    }

    override var canBecomeKey: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown, SearchBar.shared.handleKey(Int(event.keyCode)) else { return super.sendEvent(event) }
    }

    override func resignKey() {
        super.resignKey()
        SearchBar.shared.hide()
    }
}
