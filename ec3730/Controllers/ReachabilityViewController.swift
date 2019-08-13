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
import SystemConfiguration.CaptiveNetwork

class InterfaceNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class InterfaceTable: UITableViewController {
    let interface: Interface
    let interfaceInfo: NSDictionary?
    
    init(_ interface: Interface, interfaceInfo: NSDictionary? = nil) {
        self.interfaceInfo = interfaceInfo
        self.interface = interface
        super.init(style: .plain)
        self.title = self.interface.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9 + ((self.interfaceInfo != nil) ? 2 : 0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CopyDetailCell(title: NSStringFromClass(InterfaceTable.self), detail: "")
        switch indexPath.row {
        case 0:
            cell.titleLabel?.text = "Name"
            cell.detailLabel?.text = self.interface.name
            break
        case 1:
            cell.titleLabel?.text = "Address"
            cell.detailLabel?.text = self.interface.address
            break
        case 2:
            cell.titleLabel?.text = "Netmask"
            cell.detailLabel?.text = self.interface.netmask
            break
        case 3:
            cell.titleLabel?.text = "Broadcast Address"
            cell.detailLabel?.text = self.interface.broadcastAddress
            break
        case 4:
            cell.titleLabel?.text = "Family"
            cell.detailLabel?.text = self.interface.family.toString()
            break
        case 5:
            cell.titleLabel?.text = "Loopback"
            cell.detailLabel?.text = self.interface.isLoopback ? "Yes" : "No"
            break
        case 6:
            cell.titleLabel?.text = "Running"
            cell.detailLabel?.text = self.interface.isRunning ? "Yes" : "No"
            break
        case 7:
            cell.titleLabel?.text = "Up"
            cell.detailLabel?.text = self.interface.isUp ? "Yes" : "No"
            break
        case 8:
            cell.titleLabel?.text = "Supports Multicast"
            cell.detailLabel?.text = self.interface.supportsMulticast ? "Yes" : "No"
            break
        case 9:
            cell.titleLabel?.text = "SSID"
            cell.detailLabel?.text = interfaceInfo?[kCNNetworkInfoKeySSID as String] as? String
            break
        case 10:
            cell.titleLabel?.text = "BSSID"
            cell.detailLabel?.text = interfaceInfo?[kCNNetworkInfoKeyBSSID as String] as? String
            break
        default:
            break
        }
        return cell
    }
}

class NetworkInterfacesTable : UITableViewController {
    
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
        let cell = CopyDetailCell(title: NSStringFromClass(NetworkInterfacesTable.self), detail: "")
        if indexPath.section == 0 {
            let interface = self.enabledInterfaces[indexPath.row]
            cell.titleLabel?.text = interface.name
            cell.detailLabel?.text = interface.address
        } else {
            let interface = self.disabledInterfaces[indexPath.row]
            cell.titleLabel?.text = interface.name
            cell.titleLabel?.textColor = UIColor.gray
            cell.detailLabel?.text = interface.address
        }
        
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var _interface: Interface?
        if indexPath.section == 0 {
            _interface = self.enabledInterfaces[indexPath.row]
        } else {
            _interface = self.disabledInterfaces[indexPath.row]
        }
        
        _ = WiFi.ssid { (name, info) in
            if let interface = _interface {
                
                var table = InterfaceTable(interface)
                if name == interface.name {
                    table = InterfaceTable(interface, interfaceInfo: info)
                }
                self.navigationController?.pushViewController(table, animated: true)
            }
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
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
                if interface.isRunning {
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
    
    let interfaceTable = NetworkInterfacesTable()
    let iNav = InterfaceNavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        urlBar = UITextField(frame: CGRect(x: 0, y: self.view.frame.midY, width: self.view.frame.width, height: 25))
        
        stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(stack)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterX, metrics: nil, views: ["scrollview": stack!]))

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
        connectedLabel.adjustsFontSizeToFitWidth = true
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
        DispatchQueue.main.async {
            self.update()
        }
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
