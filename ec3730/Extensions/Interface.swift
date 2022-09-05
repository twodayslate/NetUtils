import Foundation
import NetUtils

#if swift(>=3.2)
    #if os(Linux)
        import Glibc
        typealias InetFamily = UInt16
        typealias Flags = Int
        func destinationAddress(_ data: ifaddrs) -> UnsafeMutablePointer<sockaddr>! { data.ifa_addr }
        func socketLength4(_: sockaddr) -> UInt32 { UInt32(MemoryLayout<sockaddr>.size) }
    #else
        import Darwin
        typealias InetFamily = UInt8
        typealias Flags = Int32
        func destinationAddress(_ data: ifaddrs) -> UnsafeMutablePointer<sockaddr>! { data.ifa_dstaddr }
        func socketLength4(_ addr: sockaddr) -> UInt32 { socklen_t(addr.sa_len) }
    #endif
#else
    import ifaddrs
    typealias InetFamily = UInt8
    typealias Flags = Int32
    func destinationAddress(_ data: ifaddrs) -> UnsafeMutablePointer<sockaddr>! { data.ifa_dstaddr }
    func socketLength4(_ addr: sockaddr) -> UInt32 { socklen_t(addr.sa_len) }
#endif

extension Interface: Identifiable {
    public var id: Int {
        "\(name)\(address ?? "")\(debugDescription)".hashValue
    }

    public var dataUsage: String {
        var ifaddrsPtr: UnsafeMutablePointer<ifaddrs>?
        var found = false
        var usage: UInt64 = 0
        if !name.hasPrefix(SystemDataUsage.wifiInterfacePrefix), !name.hasPrefix(SystemDataUsage.wwanInterfacePrefix) {
            return SystemDataUsage.humanReadableByteCount(bytes: usage)
        }
        if getifaddrs(&ifaddrsPtr) == 0 {
            var ifaddrPtr = ifaddrsPtr
            while ifaddrPtr != nil, !found {
                if let data = ifaddrPtr?.pointee {
                    let name = String(cString: data.ifa_name)
                    let address = Interface.extractAddress(data.ifa_addr)
                    if address == self.address, name == self.name {
                        found = true
                        if name.hasPrefix(SystemDataUsage.wifiInterfacePrefix) {
                            if let dataUsage = SystemDataUsage.getDataUsageInfo(from: ifaddrPtr!) {
                                usage = dataUsage.wifiSent + dataUsage.wifiReceived
                            }
                        } else if name.hasPrefix(SystemDataUsage.wwanInterfacePrefix) {
                            if let dataUsage = SystemDataUsage.getDataUsageInfo(from: ifaddrPtr!) {
                                usage = dataUsage.wirelessWanDataSent + dataUsage.wirelessWanDataReceived
                            }
                        }
                    }
                }
                ifaddrPtr = ifaddrPtr?.pointee.ifa_next
            }
            freeifaddrs(ifaddrsPtr)
        }
        return SystemDataUsage.humanReadableByteCount(bytes: usage)
    }

    static func extractAddress(_ address: UnsafeMutablePointer<sockaddr>?) -> String? {
        guard let address = address else { return nil }
        return address.withMemoryRebound(to: sockaddr_storage.self, capacity: 1) {
            if address.pointee.sa_family == sa_family_t(AF_INET) {
                return extractAddress_ipv4($0)
            } else if address.pointee.sa_family == sa_family_t(AF_INET6) {
                return extractAddress_ipv6($0)
            } else {
                return nil
            }
        }
    }

    static func extractAddress_ipv4(_ address: UnsafeMutablePointer<sockaddr_storage>) -> String? {
        address.withMemoryRebound(to: sockaddr.self, capacity: 1) { addr in
            var address: String?
            var hostname = [CChar](repeating: 0, count: Int(2049))
            if getnameinfo(&addr.pointee, socklen_t(socketLength4(addr.pointee)), &hostname,
                           socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                address = String(cString: hostname)
            }
            return address
        }
    }

    static func extractAddress_ipv6(_ address: UnsafeMutablePointer<sockaddr_storage>) -> String? {
        var addr = address.pointee
        var ip = [Int8](repeating: Int8(0), count: Int(INET6_ADDRSTRLEN))
        return inetNtoP(&addr, ip: &ip)
    }

    static func inetNtoP(_ addr: UnsafeMutablePointer<sockaddr_storage>, ip: UnsafeMutablePointer<Int8>) -> String? {
        addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { addr6 in
            let conversion: UnsafePointer<CChar> = inet_ntop(AF_INET6, &addr6.pointee.sin6_addr, ip, socklen_t(INET6_ADDRSTRLEN))
            return String(cString: conversion)
        }
    }
}
