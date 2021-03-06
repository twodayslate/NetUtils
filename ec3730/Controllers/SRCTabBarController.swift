//
//  SRCTabBarController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/23/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import SplitTabBar
import SwiftUI

class SRCTabBarController: SplitTabBarViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()

        
        var ping: UIViewController!
        if #available(iOS 14.0, *) {
            ping = UIHostingController(rootView: PingSwiftUIViewController())
        } else {
            ping = PingViewController()
        }
        ping.tabBarItem = UITabBarItem(title: "Ping", image: UIImage(named: "Ping"), tag: 0)
        ping.tabBarItem.selectedImage = UIImage(named: "Ping_selected")

        let reachability = ReachabilityViewController()
        reachability.tabBarItem = UITabBarItem(title: "Connectivity", image: UIImage(named: "Connected"), tag: 1)

        let viewSource = SourceViewController()
        viewSource.tabBarItem = UITabBarItem(title: "View Source", image: UIImage(named: "Source"), tag: 2)
        viewSource.tabBarItem.selectedImage = UIImage(named: "Source_selected")

        let host = HostViewController()
        host.tabBarItem = UITabBarItem(title: "Host", image: UIImage(named: "Network"), tag: 3)
        host.tabBarItem.selectedImage = UIImage(named: "Network_selected")

        let device = DeviceViewController()
        device.tabBarItem = UITabBarItem(title: "Device", image: UIImage(named: "Device"), tag: 3)
        device.tabBarItem.selectedImage = UIImage(named: "Device_selected")

        let settings = SettingsNavigationController()
        settings.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "Settings"), tag: 4)
        settings.tabBarItem.selectedImage = UIImage(named: "Settings_selected")

        self.setViewControllers([host, reachability, ping, viewSource, device, settings])
    }

    @objc func defaultsChanged() {
        DispatchQueue.main.async {
            switch UserDefaults.standard.integer(forKey: "theme") {
            case 1:
                self.overrideUserInterfaceStyle = .light
            case 2:
                self.overrideUserInterfaceStyle = .dark
            default:
                self.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
}
