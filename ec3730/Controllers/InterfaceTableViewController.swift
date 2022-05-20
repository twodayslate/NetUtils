//
//  InterfaceTableViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/14/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import CoreLocation
import Foundation
import NetUtils
import Reachability
import SystemConfiguration.CaptiveNetwork
import UIKit

class InterfaceTable: UITableViewController {
    let interface: Interface
    let interfaceInfo: [String: Any?]?
    let vpnInfo: [String: Any?]?

    var dataSource: [(title: String, content: Any?)] {
        var sources = [
            (title: "Name", content: interface.name),
            (title: "Address", content: interface.address),
            (title: "Netmask", content: interface.netmask),
            (title: "Broadcast Address", content: interface.broadcastAddress),
            (title: "Family", content: interface.family.toString()),
            (title: "Loopback", content: interface.isLoopback),
            (title: "Runing", content: interface.isRunning),
            (title: "Up", content: interface.isUp),
            (title: "Supports Multicast", content: interface.supportsMulticast),
        ] as [(title: String, content: Any?)]

        if let SSID = interfaceInfo?[kCNNetworkInfoKeySSID as String] as? String {
            sources.append((title: "SSID", content: SSID))
        }
        if let BSSID = interfaceInfo?[kCNNetworkInfoKeyBSSID as String] as? String {
            sources.append((title: "BSSID", content: BSSID))
        }

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

        for keys in proxyKeys {
            if let item = vpnInfo?[keys.key] {
                sources.append((title: keys.title, content: item))
            }
        }

        return sources
    }

    init(_ interface: Interface, interfaceInfo: [String: Any?]? = nil, proxyInformation: [String: Any?]? = nil) {
        self.interfaceInfo = interfaceInfo
        self.interface = interface
        vpnInfo = proxyInformation
        super.init(style: .plain)
        title = self.interface.name
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        dataSource.count
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = CopyDetailCell(title: dataSource[indexPath.row].title, detail: "") as UITableViewCell

        let content = dataSource[indexPath.row].content

        if let rar = dataSource[indexPath.row].content as? [String] {
            cell = ContactCell(reuseIdentifier: dataSource[indexPath.row].title, title: dataSource[indexPath.row].title)

            for thing in rar {
                (cell as? ContactCell)?.addRow(ContactCellRow(title: "", detail: thing))
            }
        } else if let aBool = content as? Bool {
            (cell as? CopyDetailCell)?.detailLabel?.text = aBool ? "Yes" : "No"
        } else if let aString = content as? String {
            (cell as? CopyDetailCell)?.detailLabel?.text = aString
        } else if let item = content as? Int {
            (cell as? CopyDetailCell)?.detailLabel?.text = String(describing: item)
        }

        return cell
    }
}
