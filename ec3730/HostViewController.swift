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
    
    public var dnsLookups = Set<String>() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
    }
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
            return self.dnsLookups.count
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
        var cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
    
        if (indexPath.section == 1) {
            print("is subscribed?", WhoisXml.isSubscribed)
            cell = self.whoisManger.cells[indexPath.row]
        } else {
            cell.textLabel?.text = self.dnsLookups.sorted()[indexPath.row]
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge() // https://stackoverflow.com/questions/20809164/uinavigationcontroller-bar-covers-its-uiviewcontrollers-content
        self.title = self.host + " Information"
        
        //self.tableView.register(WhoisTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(WhoisTableViewCell.self))
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        //self.tableView.separatorInset.left =  self.view.frame.width
        self.tableView.tableFooterView = UIView() // hide sepeartor
        self.tableView.reloadData()
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
    
    override func viewDidLoad() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: ApiKey.inApp.key)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = "whois.monthly.auto"
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        self.view.addSubview(stack)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterX, metrics: nil, views: ["scrollview": stack]))
        
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
        urlBar?.delegate = self
        
        barStack.addArrangedSubview(urlBar!)
        
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 120, height: 50))
        button.setTitle("Lookup", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(fetchData), for: .touchDown)
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
            self.fetchData()
            return false
        }
        return true
    }
    
    /**
     * https://stackoverflow.com/questions/25890533/how-can-i-get-a-real-ip-address-from-dns-query-in-swift
     */
    func localDnsLookup(_ server: String) -> [String] {
        var ans = [String]()
        print(server)
        let host = CFHostCreateWithName(nil,server as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
            for case let theAddress as NSData in addresses {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    ans.append(numAddress)
                }
            }
        }
        return ans
    }

    func showError(_ title : String = "Error", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getWhois(_ domain: String, completion block: ((Error?, WhoisRecord?) -> ())? = nil) {
        var error : Error? = nil
        let session = URLSession(configuration: .default)
        // check balance
        var balanceString = "https://www.whoisxmlapi.com/accountServices.php?servicetype=accountbalance"
        balanceString += "&apiKey=" + ApiKey.WhoisXML.key
        balanceString += "&output_format=JSON"
        // Example output: {"balance":497}
        if let balanceUrl = URL(string: balanceString) {
            do {
                let d = try Data(contentsOf: balanceUrl)
                if let json = try JSONSerialization.jsonObject(with: d, options: []) as? [String: Any]
                {
                    print(json)
                    if let balance = json["balance"] as? Double { // why can't this be an Int?
                        print(balance)
                        if(balance > 100) {
                            var queryString = "https://www.whoisxmlapi.com/whoisserver/WhoisService?"
                            queryString += "domainName=" + domain // TODO: stripping and verification
                            queryString += "&apiKey=" + ApiKey.WhoisXML.key
                            queryString += "&outputFormat=JSON"
                            queryString += "&da=2" // domain availability
                            queryString += "&ip=1"
                            //queryString += "&preferFresh=1" // get the latest (possibly incomplete data
                            
                            print(queryString)
                            if let queryUrl = URL(string: queryString) {
                                session.dataTask(with: queryUrl) {
                                    (data, response, error) in
                                    guard error == nil else {
                                        block?(error, nil)
                                        return
                                    }
                                    guard let data = data else {
                                        block?(WhoisError("No data"), nil)
                                        return
                                    }
                                    
                                    let decoder = JSONDecoder()
                                    decoder.dateDecodingStrategy = .custom {
                                        decoder in
                                        let container = try decoder.singleValueContainer()
                                        let dateString = try container.decode(String.self)
                                        
                                        print("dateString", dateString)
                                        let formatter = DateFormatter()
                                        let formats = [
                                            "yyyy-MM-dd HH:mm:ss",
                                            "yyyy-MM-dd",
                                            "yyyy-MM-dd HH:mm:ss.SSS ZZZ",
                                            "yyyy-MM-dd HH:mm:ss ZZZ" // 1997-09-15 07:00:00 UTC
                                        ]
                                        
                                        for format in formats {
                                            formatter.dateFormat = format
                                            if let date = formatter.date(from: dateString) {
                                                return date
                                            }
                                        }
                                        
                                        let iso = ISO8601DateFormatter()
                                        iso.timeZone = TimeZone(abbreviation: "UTC")
                                        if let date = iso.date(from: dateString) {
                                            return date
                                        }
                                        
                                        if let date = ISO8601DateFormatter().date(from: dateString) {
                                            return date
                                        }
                                        
                                        throw DecodingError.dataCorruptedError(in: container,
                                                                               debugDescription: "Cannot decode date string \(dateString)")
                                    }
                                    
                                    let output = String(data: data, encoding: .utf8)
                                    print(output) // TODO: remove
                                    
                                    do {
                                        let c = try decoder.decode(Coordinate.self, from: data)
                                        block?(nil, c.whoisRecord)
                                    } catch let decodeError {
                                        print(decodeError) // TODO: remove
                                        block?(decodeError, nil)
                                    }
                                }.resume()
                            }
                        } else {
                            error = WhoisError("WHOIS API balance low - please try again later and contact support.")
                        }
                    }
                } else {
                    error = WhoisError("Unable to parse WHOIS API balance - please try again later.")
                }
            } catch let c_error {
                error = c_error
            }
        }
        
        if let error = error {
            block?(error, nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
    
    @objc
    func fetchData() {
        if(isLoading) { return }
        
        var urlString = (urlBar?.text)!
        if(urlString == "") {
            urlString = (urlBar?.placeholder)!
        }
        
        var showError = true
        print(urlString)
        if let url = URL(string: urlString) {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            if(comps.scheme == nil && comps.host == nil && comps.path.contains(".")) {
                comps.host = comps.path
                comps.path = ""
            }
            if(comps.scheme == nil) {
                comps.scheme = "http"
            }
            var newUrl = url
            if let fixedUrl = comps.url {
                if let tmpUrl = URL(string: fixedUrl.absoluteString) {
                    newUrl = tmpUrl
                }
            }
            
            if(UIApplication.shared.canOpenURL(newUrl)) {
                if let host = newUrl.host {
                    showError = false
                    self.isLoading = true
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        print("Host fetch for: ", host)
                        // Reset values
                        self.hostTable.host = host
                        self.hostTable.dnsLookups.removeAll()
                        if WhoisXml.isSubscribed {
                            self.hostTable.whoisRecord = nil
                        }
                        
                        for ip in self.localDnsLookup(host) {
                            self.hostTable.dnsLookups.insert(ip)
                        }
                        DispatchQueue.main.async {
                            self.hostTable.tableView.reloadData()
                        }
//                        if(self.canAccessWhois) {
                        if true { // TODO: use actual value
                            self.getWhois(host) { (error, response) in
                                guard let response = response, error == nil else {
                                    return
                                }
                                
                                print(response)
                                self.hostTable.whoisRecord = response
                            }
                        }
                        
                        self.isLoading = false
                    } // async
                } // does it have a host?
            } // can I open it?
        } // is string even a url?
        
        if(showError){
            //self.status?.insertText("Invalid URL\n")
            let alert = UIAlertController(title: "Error", message: "Invalid URL", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
