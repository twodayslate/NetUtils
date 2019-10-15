//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import CoreLocation
import Foundation
import NetUtils
import Reachability
import SystemConfiguration.CaptiveNetwork
import UIKit

class InterfaceNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class NetworkInterfacesTable: UITableViewController {
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateInterfaces()
        if section == 0 {
            return enabledInterfaces.count
        } else {
            return disabledInterfaces.count
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if enabledInterfaces.count > 0, section == 0 {
            return "Enabled (Up)"
        }
        return "Disabled (Down)"
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return (enabledInterfaces.count > 0 ? 1 : 0) + (disabledInterfaces.count > 0 ? 1 : 0)
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CopyDetailCell(title: NSStringFromClass(NetworkInterfacesTable.self), detail: "")
        if indexPath.section == 0 {
            let interface = enabledInterfaces[indexPath.row]
            cell.titleLabel?.text = interface.name
            cell.detailLabel?.text = interface.address
        } else {
            let interface = disabledInterfaces[indexPath.row]
            cell.titleLabel?.text = interface.name
            cell.titleLabel?.textColor = UIColor.gray
            cell.detailLabel?.text = interface.address
        }

        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true

        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentInterface: Interface?
        if indexPath.section == 0 {
            currentInterface = enabledInterfaces[indexPath.row]
        } else {
            currentInterface = disabledInterfaces[indexPath.row]
        }

        guard let interface = currentInterface else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        _ = WiFi.ssid { name, _, info in
            let table = InterfaceTable(
                interface,
                interfaceInfo: name == interface.name ? info : nil,
                proxyInformation: WiFi.proxySettings(for: interface.name)
            )
            self.navigationController?.pushViewController(table, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    private var _cachedInterfaces = Interface.allInterfaces()

    private var _cachedDisabledInterfaces = [Interface]()
    private var _cachedEnabledInterfaces = [Interface]()

    private var cachedInterfaces: [Interface] {
        return _cachedInterfaces
    }

    public var disabledInterfaces: [Interface] {
        return _cachedDisabledInterfaces
    }

    public var enabledInterfaces: [Interface] {
        return _cachedEnabledInterfaces
    }

    public func updateInterfaces() {
        _cachedInterfaces = Interface.allInterfaces()
        _cachedEnabledInterfaces.removeAll()
        _cachedDisabledInterfaces.removeAll()

        for interface in _cachedInterfaces {
            if interface.isUp {
                _cachedEnabledInterfaces.append(interface)
            } else {
                _cachedDisabledInterfaces.append(interface)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge() // https://stackoverflow.com/questions/20809164/uinavigationcontroller-bar-covers-its-uiviewcontrollers-content
        title = "Interfaces"
    }
}

class ReachabilityViewController: UIViewController {
    var button: UIButton?

    var stack: UIStackView!

    let connectedLabel = UILabel()
    let connectedCheck = UISwitch()

    let interfaceTable = NetworkInterfacesTable()
    let iNav = InterfaceNavigationController()

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = .white
        }

        locationManager.delegate = self

        stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterX, metrics: nil, views: ["scrollview": stack!]))

        stack.addArrangedSubview(iNav.view)
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
        stack.addArrangedSubview(bar)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: Reachability.shared)
        do {
            try Reachability.shared.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }

        update()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Reachability.shared.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: Reachability.shared)
    }

    @objc
    func reachabilityChanged(note _: Notification) {
        DispatchQueue.main.async {
            self.update()
        }
    }

    private var connectedTabBarItem: UITabBarItem {
        let item = UITabBarItem(title: "Connectivity", image: UIImage(named: "Connected"), tag: 1)
        item.selectedImage = UIImage(named: "Connected_selected")
        return item
    }

    private var disconnectedTabBarItem: UITabBarItem {
        let item = UITabBarItem(title: "Connectivity", image: UIImage(named: "Disconnected"), tag: 1)
        item.selectedImage = UIImage(named: "Disconnected_selected")
        return item
    }

    func vpn(completion block: ((String?, [String: Any?]?) -> Void)? = nil) {
        let cfDict = CFNetworkCopySystemProxySettings()
        let nsDict = cfDict!.takeRetainedValue() as NSDictionary
        // swiftlint:disable:next force_cast
        let keys = nsDict["__SCOPED__"] as! NSDictionary

        if let allKeys = keys.allKeys as? [String] {
            for key: String in allKeys {
                if key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") {
                    block?(key, keys.object(forKey: key) as? [String: Any?])
                    return
                }
            }
        }
        block?(nil, nil)
    }

    @objc
    func update() {
        DispatchQueue.main.async {
            switch Reachability.shared.connection {
            case .wifi:
                self.connectedCheck.setOn(true, animated: true)
                self.tabBarItem = self.connectedTabBarItem
                self.connectedLabel.text = "Connected via WiFi"

                if #available(iOS 13.0, *) {
                    let status = CLLocationManager.authorizationStatus()
                    if status == .authorizedWhenInUse || status == .authorizedAlways {
                        if let (optionalInterface, optionalSsid, _) = WiFi.ssidInfo(), let interface = optionalInterface, let ssid = optionalSsid {
                            self.connectedLabel.text = self.connectedLabel.text! + " (\(ssid)) on \(interface)"
                        }
                    } else {
                        // XXX: add information prompt before the actual request
                        self.locationManager.requestWhenInUseAuthorization()
                        // XXX: This goes away after a second or two?... why?
                    }
                } else {
                    if let (optionalInterface, optionalSsid, _) = WiFi.ssidInfo(), let interface = optionalInterface, let ssid = optionalSsid {
                        self.connectedLabel.text = self.connectedLabel.text! + " (\(ssid)) on \(interface)"
                    }
                }

            case .cellular:
                self.connectedCheck.setOn(true, animated: true)
                self.connectedLabel.text = "Connected via Cellular"
                self.tabBarItem = self.connectedTabBarItem
            case .none:
                self.connectedCheck.setOn(false, animated: true)
                self.connectedLabel.text = "Not Connected"
                self.tabBarItem = self.disconnectedTabBarItem
            }
            self.interfaceTable.updateInterfaces()
            self.interfaceTable.tableView.reloadData()
        }
    }
}

extension ReachabilityViewController: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization auth: CLAuthorizationStatus) {
        switch auth {
        case .authorizedAlways:
            update()
        case .authorizedWhenInUse:
            update()
        default:
            break
        }
    }
}
