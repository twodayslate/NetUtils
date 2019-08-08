//
//  SRCTabBarController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/23/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class SRCTabBarController : UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ping = PingViewController()
        ping.tabBarItem = UITabBarItem(title: "Ping", image: UIImage(named: "Ping"), tag: 0)
        
        let reachability = ReachabilityViewController()
        reachability.tabBarItem = UITabBarItem(title: "Connectivity", image: UIImage(named: "Connected"), tag: 1)
        
        let viewSource = SourceViewController()
        viewSource.tabBarItem = UITabBarItem(title: "View Source", image: UIImage(named: "Source"), tag: 2)
        
        let host = HostViewController()
        host.tabBarItem = UITabBarItem(title: "Host", image: UIImage(named: "Host"), tag: 3)
        // TODO: Host
        
        self.viewControllers = [host, reachability, ping, viewSource]
    }
}
