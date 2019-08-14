//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit

class HostNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class WhoisTableViewCell: UITableViewCell {
    convenience init(reuseIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    public var response: [String: Any]? = nil
    
    func configure(_ response: [String: Any]?) {
        guard let response = response else {
            return
        }
        
        self.response = response
        
        self.textLabel?.text = "\(response)"
    }
}



class HostTable : UITableViewController {
    
    let lockIcon = UIImage(named: "Lock")
    
    var isLoading = false {
        didSet {
            if self.isLoading {
                DispatchQueue.main.async {
                    self.whoisManger.startLoading()
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    public var dnsLookups = Set<String>()
    
    public var whoisRecord: WhoisRecord? = nil {
        didSet {
            DispatchQueue.main.async {
                self.whoisManger.configure(self.whoisRecord)
                self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }
    public var whoisManger = WhoisXmlCellManager()
    
    public var _host: String = "Host"
    public var host: String {
        get {
            return _host
        }
        set {
            _host = newValue
            self.title = self.host + " Information"
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1) {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // show loading cell or the ip list
            return self.isLoading ? 1 : self.dnsLookups.count
        } else {
            return whoisManger.cells.count // WHOIS
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "A Name Lookup"
        }
        return "WHOIS"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
    
        if (indexPath.section == 1) {
            cell = self.whoisManger.cells[indexPath.row]
        } else {
            if self.isLoading || self.dnsLookups.count <= indexPath.row {
                cell = LoadingCell(reuseIdentifier: "loading")
            } else {
                cell = CopyCell(title: self.dnsLookups.sorted()[indexPath.row])
            }
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge() // https://stackoverflow.com/questions/20809164/uinavigationcontroller-bar-covers-its-uiviewcontrollers-content
        self.title = self.host + " Information"
        self.whoisManger.iapDelegate = self
        
        //self.tableView.register(WhoisTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(WhoisTableViewCell.self))
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        //self.tableView.separatorInset.left =  self.view.frame.width
        self.tableView.tableFooterView = UIView() // hide sepeartor
        self.tableView.reloadData()
    }
}

extension HostTable: InAppPurchaseUpdateDelegate {
    func verify(showErrors: Bool = true) {
        WhoisXml.verifySubscription { (error, result) in
            guard error == nil else {
                if showErrors {
                    self.parent?.showError(message: error!.localizedDescription)
                }
                return
            }
            
            guard let result = result else {
                // TODO: show error
                if showErrors {
                    self.parent?.showError(message: "Unable to verify subscription")
                }
                return
            }
            
            // TODO: show status if isn't subscribed
            switch result {
            case .purchased(_, _):
                if showErrors {
                    self.parent?.showError("❤", message: "Thank you for your purchase!")
                }
                DispatchQueue.main.async {
                    self.whoisManger.configure(self.whoisRecord)
                    self.tableView.reloadData()
                }
            case .expired(_, _):
                if showErrors {
                    self.parent?.showError("Subscription Expired", message: "Please purchase again or manage your subscription from inside the App Store")
                }
            case .notPurchased:
                if showErrors {
                    self.parent?.showError(message: "Subscription has not been purchased. Please try again laster.")
                }
            }
        }
    }
    
    func restoreInAppPurchase(_ results: RestoreResults) {
        self.verify()
    }
    
    func updatedInAppPurchase(_ result: PurchaseResult) {
        self.verify()
    }
    
    func verifyInAppSubscription(error: Error?, result: VerifySubscriptionResult?) {
        DispatchQueue.main.async {
            self.whoisManger.configure(self.whoisRecord)
            self.tableView.reloadData()
        }
    }
}

class HostViewController : UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    var urlBar : UITextField?
    var button : UIButton?
    
    var stack : UIStackView! = nil
    
    let connectedLabel = UILabel()
    let connectedCheck = UISwitch()
    
    let hostTable = HostTable()
    let iNav = HostNavigationController()
    let whoisCache = TimedCache(expiresIn: 180)
    
    override func viewDidLoad() {
        self.hostTable.verify(showErrors: false)
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        self.view.addSubview(stack)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterX, metrics: nil, views: ["scrollview": stack!]))
        
        self.stack.addArrangedSubview(iNav.view)
        iNav.setViewControllers([hostTable], animated: false)        
        hostTable.tableView.contentInsetAdjustmentBehavior = .never
        
        let barStack = UIStackView()
        barStack.axis = NSLayoutConstraint.Axis.horizontal
        barStack.alignment = .leading
        //barStack.autoresizingMask = [.flexibleWidth]
        //stack.alignment = UIStackViewAlignment.Fill
        //stack.distribution = UIStackViewDistribution.FillProportionally
        barStack.spacing = 10
        //barStack.translatesAutoresizingMaskIntoConstraints = false
        
        //urlBar = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        urlBar = UITextField()
        urlBar?.autocorrectionType = .no
        urlBar?.autocapitalizationType = .none
        urlBar?.textColor = UIColor.black
        urlBar?.textAlignment = .left
        urlBar?.borderStyle = .roundedRect
        urlBar?.keyboardType = .URL
        urlBar?.placeholder = "google.com"
        urlBar?.clearButtonMode = .whileEditing
        urlBar?.delegate = self
        
        barStack.addArrangedSubview(urlBar!)
        
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 120, height: 50))
        button.setTitle("Lookup", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(fetchDataAndDisplayError), for: .touchDown)
        barStack.addArrangedSubview(button)
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        barStack.addArrangedSubview(loader)
        
        let bar = UIToolbar()
        bar.barStyle = .blackTranslucent
        bar.setItems([UIBarButtonItem(customView: barStack)], animated: false)
        self.stack.addArrangedSubview(bar)
        
        loader.hidesWhenStopped = true
        let yConstraint = NSLayoutConstraint(item: self.loader, attribute: .centerY, relatedBy: .equal, toItem: barStack, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([yConstraint])
        self.startAvoidingKeyboard()
    }
    
    private var _isLoading = false
    var isLoading : Bool {
        get {
            return _isLoading
        }
        set {
            DispatchQueue.main.async {
                self.hostTable.isLoading = self.isLoading
                if newValue {
                    self.loader.startAnimating()
                } else {
                    self.loader.stopAnimating()
                }
            }
            _isLoading = newValue
        }
    }
    let loader = UIActivityIndicatorView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startAvoidingKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stopAvoidingKeyboard()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n" || string == "\r") {
            self.fetchDataAndDisplayError()
            return false
        }
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
    
    /// helper function to `fetchData()` to display the error that is thrown, if any
    @objc func fetchDataAndDisplayError() {
        self.dismissKeyboard()
        
        var preString = urlBar?.text
        if preString?.isEmpty ?? true {
            preString = urlBar?.placeholder
        }
        
        guard let text = preString else {
            self.showError(message: "Empty URL")
            return
        }
        
        do {
            try fetchData(with: text)
        } catch {
            self.showError("Invalid URL", message: error.localizedDescription)
        }
    }
    
    /// Gets the contents from urlBar
    func fetchData(with text: String) throws {
        if(isLoading) { return }
        var urlString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if urlString.isEmpty {
            throw URLError(.badURL)
        }

        guard var comps = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }
        
        if comps.scheme == nil && !urlString.contains("://") {
            urlString = "https://" + urlString
        }

        guard let url = URL(string: urlString)?.standardized, UIApplication.shared.canOpenURL(url), let host = url.host else {
            throw URLError(.badURL)
        }
        
        self.isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            print("Host fetch for: ", host)
            // Reset values
            self.hostTable.host = host
            self.hostTable.dnsLookups.removeAll()
            
            DNSResolver.resolve(host: host) { (error, addresses) in
                self.isLoading = false
                
                guard error == nil else {
                    self.showError(message: error!.localizedDescription)
                    return
                }
                guard let addresses = addresses else {
                    return
                }
                
                for ip in addresses {
                    self.hostTable.dnsLookups.insert(ip)
                }
            }
            
            if WhoisXml.isSubscribed {
                WhoisXml.query(host) { (error, response) in
                    guard error == nil else {
                        self.showError("Error getting WHOIS", message: error!.localizedDescription)
                        self.hostTable.whoisRecord = nil
                        return
                    }
                    
                    guard let response = response else {
                        self.showError(message: "No Whois Data")
                        self.hostTable.whoisRecord = nil
                        return
                    }

                    self.hostTable.whoisRecord = response
                }
            }
        }
    }
}
