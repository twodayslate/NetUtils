//
//  SRCTabBarController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/23/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class SRCTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()

        let ping = PingViewController()
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

        let settings = SettingsNavigationController()
        settings.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "Settings"), tag: 4)
        settings.tabBarItem.selectedImage = UIImage(named: "Settings_selected")

        viewControllers = [host, reachability, ping, viewSource, settings]
    }

    @objc func defaultsChanged() {
        if #available(iOS 13.0, *) {
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
