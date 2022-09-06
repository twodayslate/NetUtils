//
//  DataUsageModel.swift
//  ec3730
//
//  Created by Ahmad Azam on 21/08/2022.
//  Copyright © 2022 Zachary Gorak. All rights reserved.
//

import Foundation
import NetUtils

extension SystemDataUsage {
    static var wifiTotal: String {
        let usage = dataUsage.wifiSent + dataUsage.wifiReceived
        return humanReadableByteCount(bytes: usage)
    }

    static var wifiSent: String {
        humanReadableByteCount(bytes: dataUsage.wifiSent)
    }

    static var wifiReceived: String {
        humanReadableByteCount(bytes: dataUsage.wifiReceived)
    }

    static var wwanTotal: String {
        let usage = dataUsage.wirelessWanDataSent + dataUsage.wirelessWanDataReceived
        return humanReadableByteCount(bytes: usage)
    }

    static var wwanSent: String {
        humanReadableByteCount(bytes: dataUsage.wirelessWanDataSent)
    }

    static var wwanReceived: String {
        humanReadableByteCount(bytes: dataUsage.wirelessWanDataReceived)
    }

    static var totalUsage: String {
        let usage = dataUsage.wirelessWanDataSent + dataUsage.wirelessWanDataReceived + dataUsage.wifiSent + dataUsage.wifiReceived
        return humanReadableByteCount(bytes: usage)
    }

    static var dataUsage: DataUsageInfo = SystemDataUsage.getDataUsage()

    static func reload() {
        dataUsage = SystemDataUsage.getDataUsage()
    }

    static func humanReadableByteCount(bytes: UInt64) -> String {
        if bytes < 1000 { return "\(bytes) Bytes" }
        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1000, Double(exp))
        if exp <= 1 || number >= 100 {
            return String(format: "%.0f %@", number, unit)
        } else {
            // Can change the decimal percision
            return String(format: "%.1f %@", number, unit)
                .replacingOccurrences(of: ".0", with: "")
        }
    }
}

class SystemDataUsage {
    public static let wwanInterfacePrefix = "pdp_ip"
    public static let wifiInterfacePrefix = "en"

    class func getDataUsage() -> DataUsageInfo {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var dataUsageInfo = DataUsageInfo()

        guard getifaddrs(&ifaddr) == 0 else { return dataUsageInfo }
        while let addr = ifaddr {
            guard let info = getDataUsageInfo(from: addr) else {
                ifaddr = addr.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info)
            ifaddr = addr.pointee.ifa_next
        }

        freeifaddrs(ifaddr)

        return dataUsageInfo
    }

    class func getDataUsageInfo(from infoPointer: UnsafeMutablePointer<ifaddrs>) -> DataUsageInfo? {
        let pointer = infoPointer
        let name: String! = String(cString: pointer.pointee.ifa_name)
        let addr = pointer.pointee.ifa_addr.pointee
        guard addr.sa_family == UInt8(AF_LINK) else { return nil }

        return dataUsageInfo(from: pointer, name: name)
    }

    private class func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> DataUsageInfo {
        var networkData: UnsafeMutablePointer<if_data>?
        var dataUsageInfo = DataUsageInfo()

        if name.hasPrefix(wifiInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            if let data = networkData {
                dataUsageInfo.wifiSent += UInt64(data.pointee.ifi_obytes)
                dataUsageInfo.wifiReceived += UInt64(data.pointee.ifi_ibytes)
            }

        } else if name.hasPrefix(wwanInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            if let data = networkData {
                dataUsageInfo.wirelessWanDataSent += UInt64(data.pointee.ifi_obytes)
                dataUsageInfo.wirelessWanDataReceived += UInt64(data.pointee.ifi_ibytes)
            }
        }
        return dataUsageInfo
    }
}

struct DataUsageInfo {
    var wifiReceived: UInt64 = 0
    var wifiSent: UInt64 = 0
    var wirelessWanDataReceived: UInt64 = 0
    var wirelessWanDataSent: UInt64 = 0

    mutating func updateInfoByAdding(_ info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        wirelessWanDataSent += info.wirelessWanDataSent
        wirelessWanDataReceived += info.wirelessWanDataReceived
    }
}
