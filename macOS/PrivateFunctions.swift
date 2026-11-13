import AppKit

@_silgen_name("_AXUIElementGetWindow")
nonisolated func _AXUIElementGetWindow(_ element: AXUIElement, _ id: UnsafeMutablePointer<CGWindowID>) -> AXError

@_silgen_name("GetProcessForPID")
nonisolated func GetProcessForPID(_ pid: pid_t, _ process: UnsafeMutablePointer<ProcessSerialNumber>) -> OSStatus

@_silgen_name("SetFrontProcessWithOptions")
nonisolated func SetFrontProcessWithOptions(_ process: UnsafePointer<ProcessSerialNumber>, _ options: OptionBits) -> OSStatus

@_silgen_name("DCSGetActiveDictionaries")
nonisolated func DCSGetActiveDictionaries() -> Unmanaged<CFArray>?

@_silgen_name("DCSDictionaryGetShortName")
nonisolated func DCSDictionaryGetShortName(_ dictionary: CFTypeRef) -> Unmanaged<CFString>?

@_silgen_name("DCSCopyRecordsForSearchString")
nonisolated func DCSCopyRecordsForSearchString(_ dictionary: CFTypeRef, _ string: CFString, _ method: UInt64, _ maximumResults: Int) -> Unmanaged<CFArray>?

@_silgen_name("DCSRecordCopyData")
nonisolated func DCSRecordCopyData(_ record: CFTypeRef, _ version: Int) -> Unmanaged<CFString>?
