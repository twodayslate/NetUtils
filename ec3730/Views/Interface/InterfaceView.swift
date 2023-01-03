import Foundation
import NetUtils
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import UIKit

struct InterfaceView: View {
    @ObservedObject var model: ReachabilityModel
    let interface: Interface

    var body: some View {
        List {
            basicInfo()

            wifiInfo()

            let proxyKeys = [
                (key: "FTPPassive", title: "FTP Passive"),
                (key: "ExceptionsList", title: "Exceptions List"),
                (key: "RTSPEnable", title: "RTSP"),
                (key: "GopherEnable", title: "Gopher"),
                (key: "HTTPEnable", title: "HTTP"),
                (key: "FTPEnable", title: "FTP"),
                (key: "HTTPSEnable", title: "HTTPS"),
                (key: "HTTPSProxy", title: "HTTPS Proxy"),
                (key: "ProxyAutoConfigEnable", title: "Proxy Auto Configuration"),
                (key: "HTTPSPort", title: "HTTPS Port"),
                (key: "SOCKSEnable", title: "SOCKS"),
                (key: "ProxyAutoDiscoveryEnable", title: "Proxy Auto Discovery"),
                (key: "HTTPProxy", title: "HTTP Proxy"),
                (key: "ExcludeSimpleHostnames", title: "Excludes Simple Hostnames"),
            ]

            if let proxyInfo = proxyInformation {
                ForEach(proxyKeys, id: \.key) { item in
                    proxyView(item, info: proxyInfo)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(interface.name)
    }

    @ViewBuilder private func proxyView(_ item: (key: String, title: String), info proxyInfo: [String: Any?]) -> some View {
        if let value = proxyInfo[item.key] as? String {
            CopyCellType.row(title: item.title, content: value)
        } else if let values = proxyInfo[item.key] as? [String] {
            CopyCellType.multiple(title: item.title, contents: values.map { .content($0, style: .expandable) })
        } else if let value = proxyInfo[item.key] as? Int {
            CopyCellType.row(title: item.title, content: String(describing: value))
        } else if let value = proxyInfo[item.key] as? Bool {
            CopyCellType.row(title: item.title, content: value ? "Yes" : "No")
        } else if let value = proxyInfo[item.key] {
            CopyCellType.row(title: item.key, content: String(describing: value))
        }
    }

    @ViewBuilder func basicInfo() -> some View {
        CopyCellType.row(title: "Name", content: interface.name)
        if let address = interface.address {
            CopyCellType.row(title: "Address", content: address)
        }
        if let netmask = interface.netmask {
            CopyCellType.row(title: "Netmask", content: netmask)
        }
        if let broadcastAddress = interface.broadcastAddress {
            CopyCellType.row(title: "Broadcast Address", content: broadcastAddress)
        }
        CopyCellType.row(title: "Family", content: interface.family.toString())
        CopyCellType.row(title: "Loopback", content: interface.isLoopback ? "Yes" : "No")
        CopyCellType.row(title: "Runing", content: interface.isRunning ? "Yes" : "No")
        CopyCellType.row(title: "Up", content: interface.isUp ? "Yes" : "No")
        CopyCellType.row(title: "Supports Multicast", content: interface.supportsMulticast ? "Yes" : "No")
    }

    @ViewBuilder func wifiInfo() -> some View {
        if isCurrentWifiInterface, let interfaceInfo = model.wifiInterfaceInfo {
            if let SSID = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String {
                CopyCellType.row(title: "SSID", content: SSID)
            }
            if let BSSID = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String {
                CopyCellType.row(title: "BSSID", content: BSSID)
            }
        }
    }

    var isCurrentWifiInterface: Bool {
        interface.name == model.wifiInterface
    }

    var proxyInformation: [String: Any?]? {
        WiFi.proxySettings(for: interface.name)
    }
}
