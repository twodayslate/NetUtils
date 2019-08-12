//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import Reachability
import NetUtils
import CoreLocation

class InterfaceNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class InterfaceTable : UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.updateInterfaces()
        if section == 0 {
            return self.enabledInterfaces.count
        } else {
            return self.disabledInterfaces.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Enabled (On)"
        }
        return "Disabled (Off)"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "enabled")
        if indexPath.section == 0 {
            let interface = self.enabledInterfaces[indexPath.row]
            cell.textLabel?.text = interface.name
            cell.detailTextLabel?.text = interface.address
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "disabled")
            let interface = self.disabledInterfaces[indexPath.row]
            cell.textLabel?.text = interface.name
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.text = interface.address
        }
        return cell
    }
    
    private var _cachedInterfaces = Interface.allInterfaces()
    
    private var _cachedDisabledInterfaces = [Interface]()
    private var _cachedEnabledInterfaces = [Interface]()
    
    private var cachedInterfaces : [Interface] {
        return _cachedInterfaces
    }
    
    public var disabledInterfaces : [Interface] {
        return _cachedDisabledInterfaces
    }
    
    public var enabledInterfaces : [Interface] {
        return _cachedEnabledInterfaces
    }
    
    public func updateInterfaces() {
        self._cachedInterfaces = Interface.allInterfaces()
        _cachedEnabledInterfaces = [Interface]()
        _cachedDisabledInterfaces = [Interface]()
        
        for interface in self._cachedInterfaces {
            if let _ = interface.address {
                if interface.isUp {
                    _cachedEnabledInterfaces.append(interface)
                } else {
                    _cachedDisabledInterfaces.append(interface)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge() // https://stackoverflow.com/questions/20809164/uinavigationcontroller-bar-covers-its-uiviewcontrollers-content
        self.title = "Interfaces"
    }
}

class ReachabilityViewController : UIViewController {
    
    var urlBar : UITextField?
    var button : UIButton?
    
    var stack : UIStackView! = nil
    
    let connectedLabel = UILabel()
    let connectedCheck = UISwitch()
    
    let interfaceTable = InterfaceTable()
    let iNav = InterfaceNavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        urlBar = UITextField(frame: CGRect(x: 0, y: self.view.frame.midY, width: self.view.frame.width, height: 25))
        
        stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(stack)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterX, metrics: nil, views: ["scrollview": stack]))

        self.stack.addArrangedSubview(iNav.view)
        iNav.setViewControllers([interfaceTable], animated: false)
        interfaceTable.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(update))
        
        interfaceTable.tableView.contentInsetAdjustmentBehavior = .never

        let statusStack = UIStackView()
        statusStack.axis = .vertical
        statusStack.spacing = 10
        statusStack.translatesAutoresizingMaskIntoConstraints = false

        let connectedStack = UIStackView()
        connectedStack.axis = .horizontal
        connectedStack.spacing = 10
        connectedStack.translatesAutoresizingMaskIntoConstraints = false

        connectedLabel.text = "Connected"
        connectedStack.addArrangedSubview(connectedLabel)
        connectedCheck.isEnabled = false
        connectedStack.addArrangedSubview(connectedCheck)
        statusStack.addArrangedSubview(connectedStack)

        let bar = UIToolbar()
        bar.barStyle = .default
        bar.setItems([UIBarButtonItem(customView: connectedStack)], animated: false)
        self.stack.addArrangedSubview(bar)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.update()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: Reachability.shared)
        do{
            try Reachability.shared.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Reachability.shared.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: Reachability.shared)
    }
    
    @objc
    func reachabilityChanged(note: Notification) {
        self.update()
    }
    
    private let connectedTabBarItem = UITabBarItem(title: "Connectivity", image: UIImage(named: "Connected"), tag: 1)
    private let disconnectedTabBarItem = UITabBarItem(title: "Connectivity", image: UIImage(named: "Disconnected"), tag: 1)
    
    @objc
    func update() {
        switch Reachability.shared.connection {
        case .wifi:
            connectedCheck.setOn(true, animated: true)
            self.tabBarItem = connectedTabBarItem
            connectedLabel.text = "Connected via WiFi"
            
            if #available(iOS 13.0, *) {
                let status = CLLocationManager.authorizationStatus()
                if status == .authorizedWhenInUse {
                    if let ssid = getSSID() {
                        connectedLabel.text = connectedLabel.text! + " (\(ssid))"
                    }
                } else {
                    let locationManager = CLLocationManager()
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                }
            } else {
                if let ssid = getSSID() {
                    connectedLabel.text = connectedLabel.text! + " (\(ssid))"
                }
            }
            
        case .cellular:
            connectedCheck.setOn(true, animated: true)
            connectedLabel.text = "Connected via Cellular"
            self.tabBarItem = connectedTabBarItem
        case .none:
            connectedCheck.setOn(false, animated: true)
            connectedLabel.text = "Not Connected"
            self.tabBarItem = disconnectedTabBarItem
        }
        self.interfaceTable.updateInterfaces()
        self.interfaceTable.tableView.reloadData()
        //self.iNav.updateViewConstraints()
    }
}

extension ReachabilityViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.update()
    }
}
