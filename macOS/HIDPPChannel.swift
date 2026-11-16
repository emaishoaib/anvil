import Foundation
import IOKit.hid
import MouseKit
import os

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
    var onNotification: (([UInt8]) -> Void)?
    private let reportBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: reportCapacity)
    private var waiting: Waiting?
    private var lastExchange: Task<HIDPPReply?, Never>?
    private var isStopped = false
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
        isStopped = true
        IOHIDDeviceRegisterInputReportCallback(device, reportBuffer, Self.reportCapacity, nil, nil)
        onNotification = nil
        finish(with: nil)
    }

    isolated deinit {
        reportBuffer.deallocate()
    }

    /// Sends a request once every earlier one has its reply or has timed out, so only one request is ever waiting.
    func send(_ request: HIDPPRequest) async -> HIDPPReply? {
        let previous = lastExchange
        let exchange = Task {
            _ = await previous?.value
            return await self.exchange(request)
        }
        lastExchange = exchange
        return await exchange.value
    }

    private func exchange(_ request: HIDPPRequest) async -> HIDPPReply? {
        guard !isStopped else { return nil }
        nextID += 1
        let id = nextID
        return await withCheckedContinuation { continuation in
            waiting = Waiting(id: id, request: request, continuation: continuation)
            let report = request.report
            let result = report.withUnsafeBufferPointer { bytes in
                IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, CFIndex(report[0]), bytes.baseAddress!, bytes.count)
            }
            guard result == kIOReturnSuccess else {
                Logger.logitech.error("Channel \(self.logName, privacy: .public) could not send \(request.logBytes, privacy: .public), error \(result)")
                return finish(with: nil)
            }
            Task {
                try? await Task.sleep(for: Self.replyTimeout)
                guard waiting?.id == id else { return }
                Logger.logitech.info("Channel \(self.logName, privacy: .public) got no reply to \(request.logBytes, privacy: .public)")
                finish(with: nil)
            }
        }
    }

    private func received(_ report: [UInt8]) {
        guard let waiting, let reply = HIDPPReply(report: report, answering: waiting.request) else {
            onNotification?(report)
            return
        }
        if case .error(let code) = reply {
            Logger.logitech.info("Channel \(self.logName, privacy: .public) was refused \(waiting.request.logBytes, privacy: .public), error \(code)")
        }
        finish(with: reply)
    }

    private func finish(with reply: HIDPPReply?) {
        guard let waiting else { return }
        self.waiting = nil
        waiting.continuation.resume(returning: reply)
    }
}
