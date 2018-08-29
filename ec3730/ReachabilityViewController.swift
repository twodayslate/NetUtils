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

extension Reachability {
    static let shared = Reachability()!
}

class InterfaceTable : UITableView, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.interfaces.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let interface = self.interfaces[indexPath.row]
        cell.textLabel?.text = interface.name
        cell.detailTextLabel?.text = interface.address

        return cell
    }
    
    private var _cachedInterfaces = Interface.allInterfaces()
    
    private var cachedInterfaces : [Interface] {
        var retVal = [Interface]()
        for interface in self._cachedInterfaces {
            if let _ = interface.address {
                if interface.isUp {
                    retVal.append(interface)
                }
            }
        }
        return retVal
    }
    
    var interfaces : [Interface] {
        return cachedInterfaces
    }
    
    public func updateInterfaces() {
        self._cachedInterfaces = Interface.allInterfaces()
    }
    
    override func reloadData() {
        self.updateInterfaces()
        super.reloadData()
    }
}

class ReachabilityViewController : UIViewController {
    
    var urlBar : UITextField?
    var button : UIButton?
    
    var stack : UIStackView! = nil
    
    let connectedCheck = UISwitch()
    let wifiCheck = UISwitch()
    let cellCheck = UISwitch()
    
    let interfaceTable = InterfaceTable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        urlBar = UITextField(frame: CGRect(x: 0, y: self.view.frame.midY, width: self.view.frame.width, height: 25))
        
        stack = UIStackView()
        stack.backgroundColor = UIColor.black
        stack.axis = UILayoutConstraintAxis.vertical
        //stack.alignment = UIStackViewAlignment.fill
        //stack.alignment = .top
        //stack.distribution = UIStackViewDistribution.fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stack)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        
        
        interfaceTable.delegate = interfaceTable
        interfaceTable.dataSource = interfaceTable
        self.stack.addArrangedSubview(interfaceTable)
        
        
        let connectedStack = UIStackView()
        connectedStack.axis = .horizontal
        connectedStack.spacing = 10
        connectedStack.translatesAutoresizingMaskIntoConstraints = false
        
        let connectedLabel = UILabel()
        connectedLabel.text = "Connected"
        connectedStack.addArrangedSubview(connectedLabel)
        connectedCheck.isEnabled = false
        connectedStack.addArrangedSubview(connectedCheck)
        stack.addArrangedSubview(connectedStack)
        
        let wifiStack = UIStackView()
        wifiStack.axis = .horizontal
        wifiStack.spacing = 10
        wifiStack.translatesAutoresizingMaskIntoConstraints = false
        
        let wifiLabel = UILabel()
        wifiLabel.text = "WiFi"
        wifiStack.addArrangedSubview(wifiLabel)
        wifiCheck.isEnabled = false
        wifiStack.addArrangedSubview(wifiCheck)
        stack.addArrangedSubview(wifiStack)
        
        let cellStack = UIStackView()
        cellStack.axis = .horizontal
        cellStack.spacing = 10
        cellStack.translatesAutoresizingMaskIntoConstraints = false
        
        let cellLabel = UILabel()
        cellLabel.text = "Cellular"
        cellStack.addArrangedSubview(cellLabel)
        cellCheck.isEnabled = false
        cellStack.addArrangedSubview(cellCheck)
        stack.addArrangedSubview(cellStack)
        
        //button = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        //button?.buttonType = .roundedRect
        button = UIButton(type: .system)
        button?.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        //button?.backgroundColor = UIColor.red
        button?.isEnabled = true
        //button?.layer.borderWidth = 1
        button?.setTitle("Update", for: .normal)
        button?.titleLabel?.textColor = UIColor.green
        self.stack.addArrangedSubview(button!)
        button?.addTarget(self, action: #selector(update), for: UIControlEvents.touchDown)
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
    
    @objc
    func update() {
        switch Reachability.shared.connection {
        case .wifi:
            connectedCheck.setOn(true, animated: true)
            wifiCheck.setOn(true, animated: true)
            cellCheck.setOn(false, animated: true)
        case .cellular:
            connectedCheck.setOn(true, animated: true)
            wifiCheck.setOn(false, animated: true)
            cellCheck.setOn(true, animated: true)
        case .none:
            connectedCheck.setOn(false, animated: true)
            wifiCheck.setOn(false, animated: true)
            cellCheck.setOn(false, animated: true)
        }
        self.interfaceTable.reloadData()
    }
    
}
