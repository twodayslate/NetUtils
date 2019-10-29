//
//  DeviceController.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/28/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

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
        return 1
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
            ("Memory", "\(info.physicalMemory)"),
            ("Globally Unique String", "\(info.globallyUniqueString)"),
            ("OS Version", info.operatingSystemVersionString),
            ("System Uptime", "\(info.systemUptime)"),
            ("Hardware Model", UIDevice.current.hwModel),
            ("Hardware Machine", UIDevice.current.hwMachine),
            ("Disk Space Available", "\(UIDevice.current.freeDiskSpaceInBytes) bytes"),
            ("Total Disk Space", "\(UIDevice.current.totalDiskSpaceInBytes) bytes"),
        ]

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

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return deviceEntries.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = deviceEntries[indexPath.row]
        return CopyDetailCell(title: item.0, detail: item.1)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
