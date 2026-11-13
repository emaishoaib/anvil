import Foundation
import IOKit.hid
import MouseKit

final class HIDPPChannel {
    private static let replyTimeout = Duration.seconds(1)
    private static let reportCapacity = 64

    private struct Waiting {
        let id: Int
        let request: HIDPPRequest
        let continuation: CheckedContinuation<HIDPPReply?, Never>
    }

    let device: IOHIDDevice
    let id = UUID().uuidString
    private let reportBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: reportCapacity)
    private var waiting: Waiting?
    private var nextID = 0

    init(device: IOHIDDevice) {
        self.device = device
        IOHIDDeviceRegisterInputReportCallback(device, reportBuffer, Self.reportCapacity, { context, _, _, _, _, report, length in
            guard let context else { return }
            let channel = Unmanaged<HIDPPChannel>.fromOpaque(context).takeUnretainedValue()
            let bytes = Array(UnsafeBufferPointer(start: report, count: length))
            MainActor.assumeIsolated { channel.received(bytes) }
        }, Unmanaged.passUnretained(self).toOpaque())
    }

    func stop() {
        IOHIDDeviceRegisterInputReportCallback(device, reportBuffer, Self.reportCapacity, nil, nil)
        finish(with: nil)
    }

    isolated deinit {
        reportBuffer.deallocate()
    }

    func send(_ request: HIDPPRequest) async -> HIDPPReply? {
        nextID += 1
        let id = nextID
        return await withCheckedContinuation { continuation in
            waiting = Waiting(id: id, request: request, continuation: continuation)
            let report = request.report
            let result = report.withUnsafeBufferPointer { bytes in
                IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, CFIndex(report[0]), bytes.baseAddress!, bytes.count)
            }
            guard result == kIOReturnSuccess else { return finish(with: nil) }
            Task {
                try? await Task.sleep(for: Self.replyTimeout)
                if waiting?.id == id { finish(with: nil) }
            }
        }
    }

    private func received(_ report: [UInt8]) {
        guard let waiting, let reply = HIDPPReply(report: report, answering: waiting.request) else { return }
        finish(with: reply)
    }

    private func finish(with reply: HIDPPReply?) {
        guard let waiting else { return }
        self.waiting = nil
        waiting.continuation.resume(returning: reply)
    }
}
