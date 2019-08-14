//
//  SimplePingAdapter.swift
//  Pods
//
//  Created by Jonas Schoch on 11.02.16.
//
//

import Foundation

protocol SimplePingAdapterDelegate {
    func didSendPing()
    func didReceivePong()
    func didFailPingWithError(_ error: Error)
}

class SimplePingAdapter: NSObject, SimplePingDelegate {
    var delegate: SimplePingAdapterDelegate?

    fileprivate var pinger: SimplePing!
    fileprivate var timeoutTimer: Timer?
    fileprivate var timeoutDuration: TimeInterval = 3

    func startPing(_ hostName: String, timeout: TimeInterval = 3) {
        timeoutDuration = timeout

        pinger = SimplePing(hostName: hostName)
        pinger.delegate = self
        pinger.start()
    }

    func stopPinging() {
        if let pinger = pinger {
            pinger.stop()
        }

        if timeoutTimer != nil {
            timeoutTimer?.invalidate()
            timeoutTimer = nil
        }
    }

    @objc func timeout() {
        let userInfo: [String: Any] =
            [
                NSLocalizedDescriptionKey: NSLocalizedString("ping timed out", value: "Hostname or address not reachable, or network is powered off", comment: ""),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("ping timed out", value: "Please check the hostname or the address", comment: ""),
            ]
        let err = NSError(domain: "PlainPingErrorDomain", code: -100, userInfo: userInfo)

        delegate?.didFailPingWithError(err)
        stopPinging()
    }

    // MARK: - Simple Ping Delegates

    func simplePing(_ pinger: SimplePing, didStartWithAddress _: Data) {
        timeoutTimer = Timer.scheduledTimer(timeInterval: timeoutDuration, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
        pinger.send(with: nil)
    }

    func simplePing(_: SimplePing, didSendPacket _: Data, sequenceNumber _: UInt16) {
        delegate?.didSendPing()
    }

    func simplePing(_: SimplePing, didReceivePingResponsePacket _: Data, sequenceNumber _: UInt16) {
        delegate?.didReceivePong()
        stopPinging()
    }

    func simplePing(_: SimplePing, didReceiveUnexpectedPacket _: Data) {
        stopPinging()
    }

    func simplePing(_: SimplePing, didFailToSendPacket _: Data, sequenceNumber _: UInt16, error: Error) {
        delegate?.didFailPingWithError(error)
        stopPinging()
    }

    func simplePing(_: SimplePing, didFailWithError error: Error) {
        delegate?.didFailPingWithError(error)
        stopPinging()
    }
}
