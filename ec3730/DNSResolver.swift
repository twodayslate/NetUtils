// https://github.com/lyft/Kronos/blob/master/Sources/DNSResolver.swift

import Foundation

private let kCopyNoOperation = unsafeBitCast(0, to: CFAllocatorCopyDescriptionCallBack.self)
private let kDefaultTimeout = 8.0

enum DNSResolverError: Error {
    case timeout
}

final class DNSResolver {
    private var completion: ((Error?, [String]?) -> Void)?
    private var timer: Timer?

    private init() {}

    /// Performs DNS lookups and calls the given completion with the answers that are returned from the name
    /// server(s) that were queried.
    ///
    /// - parameter host:       The host to be looked up.
    /// - parameter timeout:    The connection timeout.
    /// - parameter completion: A completion block that will be called both on failure and success with a list
    ///                         of IPs.
    static func resolve(host: String, timeout: TimeInterval = kDefaultTimeout,
                        completion block: ((Error?, [String]?) -> Void)?) {
        let callback: CFHostClientCallBack = { host, _, _, info in
            guard let info = info else {
                return
            }
            let retainedSelf = Unmanaged<DNSResolver>.fromOpaque(info)
            let resolver = retainedSelf.takeUnretainedValue()
            resolver.timer?.invalidate()
            resolver.timer = nil

            var resolved: DarwinBoolean = false
            guard let addresses = CFHostGetAddressing(host, &resolved), resolved.boolValue else {
                resolver.completion?(nil, [])
                retainedSelf.release()
                return
            }

            var ans = [String]()
            for case let theAddress as NSData in addresses.takeUnretainedValue() as NSArray {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    ans.append(numAddress)
                }
            }

            resolver.completion?(nil, ans)
            retainedSelf.release()
        }

        let resolver = DNSResolver()
        resolver.completion = block

        let retainedClosure = Unmanaged.passRetained(resolver).toOpaque()
        var clientContext = CFHostClientContext(version: 0, info: UnsafeMutableRawPointer(retainedClosure),
                                                retain: nil, release: nil, copyDescription: kCopyNoOperation)

        let hostReference = CFHostCreateWithName(kCFAllocatorDefault, host as CFString).takeUnretainedValue()
        resolver.timer = Timer.scheduledTimer(timeInterval: timeout, target: resolver,
                                              selector: #selector(DNSResolver.onTimeout),
                                              userInfo: hostReference, repeats: false)

        CFHostSetClient(hostReference, callback, &clientContext)
        CFHostScheduleWithRunLoop(hostReference, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        CFHostStartInfoResolution(hostReference, .addresses, nil)
    }

    @objc
    private func onTimeout() {
        defer {
            self.completion?(DNSResolverError.timeout, nil)

            // Manually release the previously retained self.
            Unmanaged.passUnretained(self).release()
        }

        guard let userInfo = self.timer?.userInfo else {
            return
        }

        let hostReference = unsafeBitCast(userInfo as AnyObject, to: CFHost.self)
        CFHostCancelInfoResolution(hostReference, .addresses)
        CFHostUnscheduleFromRunLoop(hostReference, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        CFHostSetClient(hostReference, nil, nil)

        completion?(DNSResolverError.timeout, nil)
    }
}
