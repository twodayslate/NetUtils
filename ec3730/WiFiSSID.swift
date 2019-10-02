// https://github.com/HackingGate/iOS13-WiFi-Info

import Foundation
import SystemConfiguration.CaptiveNetwork

func getSSID() -> String? {
    var ssid: String?
    if let interfaces = CNCopySupportedInterfaces() as NSArray? {
        for interface in interfaces {
            // swiftlint:disable:next force_cast
            if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                // Can also see BSSID and SSIDDATA
                ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                break
            }
        }
    }
    return ssid
}

open class WiFi {
    // swiftlint:disable:next large_tuple
    public class func ssidInfo() -> (interface: String?, ssid: String?, info: [String: Any?]?)? {
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interfaceKey in interfaces {
                // swiftlint:disable:next force_cast
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interfaceKey as! CFString) as NSDictionary? {
                    let interface = interfaceKey as? String
                    let ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    let info = interfaceInfo as? [String: Any?]
                    return (interface, ssid, info)
                }
            }
        }
        return nil
    }

    // completion block wrapper for ssidInfo
    public class func ssid(completion block: ((String?, String?, [String: Any?]?) -> Void)? = nil) -> String? {
        if let (interface, ssid, info) = WiFi.ssidInfo() {
            block?(interface, ssid, info)
            return ssid
        } else {
            block?(nil, nil, nil)
            return nil
        }
    }

    public class func proxySettings(for interface: String) -> [String: Any?]? {
        let cfDict = CFNetworkCopySystemProxySettings()
        let nsDict = cfDict!.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary else {
            return nil
        }

        return keys.object(forKey: interface) as? [String: Any?]
    }
}
