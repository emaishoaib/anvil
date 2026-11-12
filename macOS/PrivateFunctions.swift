import AppKit

@_silgen_name("_AXUIElementGetWindow")
nonisolated func _AXUIElementGetWindow(_ element: AXUIElement, _ id: UnsafeMutablePointer<CGWindowID>) -> AXError

@_silgen_name("GetProcessForPID")
nonisolated func GetProcessForPID(_ pid: pid_t, _ process: UnsafeMutablePointer<ProcessSerialNumber>) -> OSStatus

@_silgen_name("SetFrontProcessWithOptions")
nonisolated func SetFrontProcessWithOptions(_ process: UnsafePointer<ProcessSerialNumber>, _ options: OptionBits) -> OSStatus
