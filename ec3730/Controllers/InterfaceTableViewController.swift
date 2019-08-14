//
//  InterfaceTableViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/14/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import Reachability
import NetUtils
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class InterfaceTable: UITableViewController {
    let interface: Interface
    let interfaceInfo: [String: Any?]?
    let vpnInfo: [String: Any?]?
    
    var dataSource: [(title: String, content: Any?)] {
        var sources =  [
            (title: "Name", content: self.interface.name),
            (title: "Address", content: self.interface.address),
            (title: "Netmask", content: self.interface.netmask),
            (title: "Broadcast Address", content: self.interface.broadcastAddress),
            (title: "Family", content: self.interface.family.toString()),
            (title: "Loopback", content: self.interface.isLoopback),
            (title: "Runing", content: self.interface.isRunning),
            (title: "Up", content: self.interface.isUp),
            (title: "Supports Multicast", content: self.interface.supportsMulticast)
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
            if let item = self.vpnInfo?[keys.key] {
                sources.append((title: keys.title, content: item))
            }
        }

        return sources
    }
    
    init(_ interface: Interface, interfaceInfo: [String: Any?]? = nil, proxyInformation: [String: Any?]? = nil) {
        self.interfaceInfo = interfaceInfo
        self.interface = interface
        self.vpnInfo = proxyInformation
        super.init(style: .plain)
        self.title = self.interface.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = CopyDetailCell(title: self.dataSource[indexPath.row].title, detail: "") as UITableViewCell
        
        let content = self.dataSource[indexPath.row].content
        
        if let rar = self.dataSource[indexPath.row].content as? [String] {
            cell = ContactCell(reuseIdentifier: self.dataSource[indexPath.row].title, title: self.dataSource[indexPath.row].title)
            
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
