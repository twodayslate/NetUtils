//
//  DeviceController.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/28/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore
import WebKit
import MachO
import DeviceKit
import CoreTelephony

class DeviceViewController: UINavigationController {
    init() {
        super.init(rootViewController: UIDeviceTableViewController())
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UIDeviceTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Device"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
    }

    @objc func reload() {
        tableView.reloadData()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return hasCarriers ? 5 : 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Memory"
        case 2: return "JavaScriptCore"
        case 3: return "Fingerprints"
        case 4:
            return "Cellular Providers"
        default:
            return nil
        }
    }
    
    var hasCarriers: Bool {
        return (CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.count ?? 0) > 0
    }
    
    var carrierEntires: [(String, String)] {
        var ans = [(String, String)]()
        guard self.hasCarriers, let providers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders else {
            return ans
        }
        for (i, carrier) in providers.enumerated() {
            if let name = carrier.value.carrierName {
                ans.append(("Provider \(i) Carrier Name", name))
            }
            ans.append(("Provider \(i) Allows VOIP", carrier.value.allowsVOIP ? "Yes" : "No"))
            if let value = carrier.value.isoCountryCode {
                ans.append(("Provider \(i) ISO Country Code", value))
            }
            if let value = carrier.value.mobileCountryCode {
                ans.append(("Provider \(i) Mobile Country Code", value))
            }
            if let value = carrier.value.mobileNetworkCode {
                ans.append(("Provider \(i) Mobile Network Code", value))
            }
        }
        return ans
    }

    var deviceEntries: [(String, String)] {
        let info = ProcessInfo.processInfo

        var ans: [(String, String)] = [
            ("Model", UIDevice.current.model),
            ("Localized Model", UIDevice.current.localizedModel),
            ("Name", UIDevice.current.name),
            ("System Name", UIDevice.current.systemName),
            ("System Version", UIDevice.current.systemVersion),
            ("UUID", UIDevice.current.identifierForVendor?.uuidString ?? "?"),
            ("Idiom", UIDevice.current.userInterfaceIdiom.description ?? "?"),
            ("Process Name", info.processName),
            ("Active Processors", "\(info.activeProcessorCount)"),
            ("Hostname", "\(info.hostName)"),
            ("Process Arguments", "\(info.arguments.joined(separator: " "))"),
            ("Low Power Mode", info.isLowPowerModeEnabled ? "Yes" : "No"),
            ("Supports Multitasking", UIDevice.current.isMultitaskingSupported ? "Yes" : "No"),
            ("Physical Memory", "\(info.physicalMemory) bytes"),
            ("Globally Unique String", "\(info.globallyUniqueString)"),
            ("OS Version", info.operatingSystemVersionString),
            ("System Uptime", "\(info.systemUptime)"),
            ("Hardware Model", UIDevice.current.hwModel),
            ("Hardware Machine", UIDevice.current.hwMachine),
            ("Disk Space Available", "\(UIDevice.current.freeDiskSpaceInBytes) bytes"),
            ("Total Disk Space", "\(UIDevice.current.totalDiskSpaceInBytes) bytes"),
            ("Device", "\(Device.current.safeDescription)"),
            ("Supports 3D Touch", Device.current.has3dTouchSupport ? "Yes" : "No"),
            ("Has Biometric Sensor", Device.current.hasBiometricSensor ? "Yes" : "No"),
            ("Diagonal Length", "\(Device.current.diagonal) inches"),
            ("Brightness", "\(Device.current.screenBrightness)%"),
            ("Has Lidar", Device.current.hasLidarSensor ? "Yes" : "No"),
            ("Has Camera", Device.current.hasCamera ? "Yes" : "No"),
            ("Has Wide Camera", Device.current.hasWideCamera ? "Yes" : "No"),
            ("Has Sensor Housing", Device.current.hasSensorHousing ? "Yes" : "No"),
            ("Has Telephoto Camera", Device.current.hasTelephotoCamera ? "Yes" : "No"),
            ("Has Ultrawide Camera", Device.current.hasUltraWideCamera ? "Yes" : "No"),
            ("Has Rounded Display Corners", Device.current.hasRoundedDisplayCorners ? "Yes" : "No"),
            
            
        ]

        func getArchitecture() -> NSString {
            let info = NXGetLocalArchInfo()
            return NSString(utf8String: (info?.pointee.description)!)!
        }
        
        ans.append(("Architecture", getArchitecture() as String))
        
        if let bootTime = UIDevice.current.boottime {
            ans.append(("Boot time", "\(bootTime)"))
            ans.append(("Total Uptime", "\(UIDevice.current.uptime)"))
        }

        if UIDevice.current.batteryLevel >= 0, UIDevice.current.batteryState != .unknown, UIDevice.current.isBatteryMonitoringEnabled {
            ans.append(("Battery Level", "\(UIDevice.current.batteryLevel * 100)%"))
            ans.append(("Battery State", "\(UIDevice.current.batteryState.description ?? "?")"))
        } else {
            ans.append(("Battery", "Battery monitoring is not enabled"))
        }

        return ans
    }
    
    var memoryEntries: [(String, String)] {
        var ans: [(String, String)] = []
        func memoryFootprint() -> Float? {
                // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
                // complex for the Swift C importer, so we have to define them ourselves.
                let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
                let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
                var info = task_vm_info_data_t()
                var count = TASK_VM_INFO_COUNT
                let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
                    infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                        task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
                    }
                }
                guard
                    kr == KERN_SUCCESS,
                    count >= TASK_VM_INFO_REV1_COUNT
                    else { return nil }
                
                let usedBytes = Float(info.phys_footprint)
                return usedBytes
            }
            
            func formattedMemoryFootprint() -> String
            {
                let usedBytes: UInt64? = UInt64(memoryFootprint() ?? 0)
                let usedMB = Double(usedBytes ?? 0) / 1024 / 1024
                let usedMBAsString: String = String(format: "%0.02f MB", usedMB)
                return usedMBAsString
             }
        ans.append(("Memory Footprint", formattedMemoryFootprint()))
        
        let tags = ["free", "active", "inactive", "wired", "zero_filled", "reactivations", "pageins", "pageouts", "faults", "cow", "lookups", "hits"]
        
        // https://github.com/PerfectlySoft/Perfect-SysInfo/blob/master/Sources/PerfectSysInfo/PerfectSysInfo.swift#L359
        func vm_stat() -> [String: Int] {
            let size = MemoryLayout<vm_statistics>.size / MemoryLayout<integer_t>.size
                    let pStat = UnsafeMutablePointer<integer_t>.allocate(capacity: size)
                    var stat: [String: Int] = [:]
                    var count = mach_msg_type_number_t(size)
                    if 0 == host_statistics(mach_host_self(), HOST_VM_INFO, pStat, &count){
                      let array = Array(UnsafeBufferPointer(start: pStat, count: size))
                      let tags = ["free", "active", "inactive", "wired", "zero_filled", "reactivations", "pageins", "pageouts", "faults", "cow", "lookups", "hits"]
                      let cnt = min(tags.count, array.count)
                      for i in 0 ... cnt - 1 {
                        let key = tags[i]
                        let value = array[i]
                        stat[key] = Int(value) / 256
                      }//next i
                    }//end if
                    pStat.deallocate()
                    return stat
        }
        
        func ggsdf() -> (kern_return_t, vm_size_t) {
            var pageSize: vm_size_t = 0
            let result = withUnsafeMutablePointer(to: &pageSize) { (size) -> kern_return_t in
                host_page_size(mach_host_self(), size)
            }

            return (result, pageSize)
        }
        
        let (kern_result, page_size) = ggsdf()
        if kern_result == KERN_SUCCESS {
            ans.append(("Page Size", "\(page_size) bytes"))
        }
        let stats = vm_stat()
        
        for key in tags {
            if let val = stats[key] {
                ans.append((key, String(format: "%d MB", val)))
            }
        }

        return ans
    }
    
    var jsEntries: [(String, String)] {
        guard let context = JSContext() else {
            return []
        }
        var ans: [(String, String)] = []
        
        if let pi = context.evaluateScript("Math.PI"), pi.isNumber{
            ans.append(("PI", "\(pi.toDouble())"))
        }
        
        if let value = context.evaluateScript("Math.E"), value.isNumber{
            ans.append(("Euler's constant", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Math.random()"), value.isNumber{
            ans.append(("Random", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Math.log(2)"), value.isNumber{
            ans.append(("Natural log of 2", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Math.log(10)"), value.isNumber{
            ans.append(("Natural log of 10", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Math.log2(10)"), value.isNumber{
            ans.append(("Base 2 logarithm of 10", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Math.log2(Math.E)"), value.isNumber{
            ans.append(("Base 2 logarithm of E", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Math.sqrt(2)"), value.isNumber{
            ans.append(("Square root of 2", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Math.sqrt(1/2)"), value.isNumber{
            ans.append(("Square root of 1/2", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Number.MAX_SAFE_INTEGER"), value.isNumber, let str = value.toNumber()?.stringValue{
            ans.append(("Maxmimum Safe Integer", str))
        }
        
        if let value = context.evaluateScript("Number.MIN_SAFE_INTEGER"), value.isNumber, let str = value.toNumber()?.stringValue{
            ans.append(("Minimum Safe Integer", str))
        }
        
        if let value = context.evaluateScript("Number.EPSILON"), value.isNumber, let str = value.toNumber()?.stringValue{
            ans.append(("Epsilon", str))
        }
        
        if let value = context.evaluateScript("Number.MAX_VALUE"), value.isNumber{
            ans.append(("Maximum Value", "\(value.toDouble())"))
        }
        
        if let value = context.evaluateScript("Number.MIN_VALUE"), value.isNumber{
            ans.append(("Minimum Value", "\(value.toDouble())"))
        }

        return ans
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return deviceEntries.count
        case 1:
            return memoryEntries.count
        case 2:
            return jsEntries.count
        case 3: // fingerprints
            return 1
        case 4:
            return carrierEntires.count
        default:
            fatalError("Unknown section")
        }
        
    }
    
    var fingerprintCellWrapperDelegate = DevpowerapiNavigationCellWrapper()

    var netutilsFingerPrintCellWrapperDelegate = NetUtilsNavigationCellWrapper()
    
    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let item = deviceEntries[indexPath.row]
            return CopyDetailCell(title: item.0, detail: item.1)
        case 1:
            let item = memoryEntries[indexPath.row]
            return CopyDetailCell(title: item.0, detail: item.1)
        case 2:
            let item = jsEntries[indexPath.row]
            return CopyDetailCell(title: item.0, detail: item.1)
        case 3:
            let cell = WKCopyDetailCell(title: "Browser Fingerprint", detail: "-")
            
            switch indexPath.row {
            default:
                cell.webview.load(URLRequest(url: URL(string: "https://fingerprint.netutils.workers.dev/")!))
                self.netutilsFingerPrintCellWrapperDelegate.cell = cell
                cell.webview.navigationDelegate = self.netutilsFingerPrintCellWrapperDelegate
            }
            return cell
        case 4:
            let item = carrierEntires[indexPath.row]
            return CopyDetailCell(title: item.0, detail: item.1)
        default:
            fatalError("Unknown section")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class DevpowerapiNavigationCellWrapper: NSObject, WKNavigationDelegate {
    var cell: CopyDetailCell? = nil
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.innerText.toString()", completionHandler: { json, _ in
            guard let json = json as? String, let jsonData = json.data(using: .utf8) else {
                return
            }
            guard let d = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String?] else {
                return
            }
            if let htmlString = d["fingerprint"] {
                DispatchQueue.main.async {
                    self.cell?.detailLabel?.text = htmlString
                }
            }
        })
    }
}

class WKCopyDetailCell: CopyDetailCell {
    var webview = WKWebView()
    override init(title: String, detail: String) {
        super.init(title: title, detail: detail)
        self.webview.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        self.webview.alpha = 0.05
        self.addSubview(self.webview)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NetUtilsNavigationCellWrapper: NSObject, WKNavigationDelegate {
    var cell: CopyDetailCell? = nil
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.innerText.toString()", completionHandler: { text, _ in
            guard let htmlString = text as? String else {
                return
            }
            
            DispatchQueue.main.async {
                self.cell?.detailLabel?.text = htmlString
            }
        })
    }
}
