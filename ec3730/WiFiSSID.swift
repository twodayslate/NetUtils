// https://github.com/HackingGate/iOS13-WiFi-Info

import Foundation
import SystemConfiguration.CaptiveNetwork

func getSSID() -> String? {
    var ssid: String?
    if let interfaces = CNCopySupportedInterfaces() as NSArray? {
        for interface in interfaces {
            if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                // Can also see BSSID and SSIDDATA
                ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                break
            }
        }
    }
    return ssid
}
