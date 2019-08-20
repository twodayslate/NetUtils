//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import UIKit

class HostNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class WhoisTableViewCell: UITableViewCell {
    convenience init(reuseIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    public var response: [String: Any]?

    func configure(_ response: [String: Any]?) {
        guard let response = response else {
            return
        }

        self.response = response

        textLabel?.text = "\(response)"
    }
}

class HostViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    var urlBar: UITextField?
    var button: UIButton?

    var stack: UIStackView!

    let connectedLabel = UILabel()
    let connectedCheck = UISwitch()

    let hostTable = HostTable()
    let iNav = HostNavigationController()
    let whoisCache = TimedCache(expiresIn: 180)

    override func viewDidLoad() {
        hostTable.verify(showErrors: false)

        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        view.addSubview(stack)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterX, metrics: nil, views: ["scrollview": stack!]))

        stack.addArrangedSubview(iNav.view)
        iNav.setViewControllers([hostTable], animated: false)
        hostTable.tableView.contentInsetAdjustmentBehavior = .never

        let barStack = UIStackView()
        barStack.axis = NSLayoutConstraint.Axis.horizontal
        barStack.alignment = .leading
        // barStack.autoresizingMask = [.flexibleWidth]
        // stack.alignment = UIStackViewAlignment.Fill
        // stack.distribution = UIStackViewDistribution.FillProportionally
        barStack.spacing = 10
        // barStack.translatesAutoresizingMaskIntoConstraints = false

        // urlBar = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
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
        stack.addArrangedSubview(bar)

        loader.hidesWhenStopped = true
        let yConstraint = NSLayoutConstraint(item: loader, attribute: .centerY, relatedBy: .equal, toItem: barStack, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([yConstraint])
        startAvoidingKeyboard()
    }

    private var _isLoading = false
    var isLoading: Bool {
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
        startAvoidingKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopAvoidingKeyboard()
    }

    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if string == "\n" || string == "\r" {
            fetchDataAndDisplayError()
            return false
        }
        return true
    }

    func scrollViewDidScroll(_: UIScrollView) {
        dismissKeyboard()
    }

    /// helper function to `fetchData()` to display the error that is thrown, if any
    @objc func fetchDataAndDisplayError() {
        dismissKeyboard()

        var preString = urlBar?.text
        if preString?.isEmpty ?? true {
            preString = urlBar?.placeholder
        }

        guard let text = preString else {
            showError(message: "Empty URL")
            return
        }

        do {
            try fetchData(with: text)
        } catch {
            showError("Invalid URL", message: error.localizedDescription)
        }
    }

    /// Gets the contents from urlBar
    func fetchData(with text: String) throws {
        if isLoading { return }
        var urlString = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if urlString.isEmpty {
            throw URLError(.badURL)
        }

        guard var comps = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }

        if comps.scheme == nil, !urlString.contains("://") {
            urlString = "https://" + urlString
        }

        guard let url = URL(string: urlString)?.standardized, UIApplication.shared.canOpenURL(url), let host = url.host else {
            throw URLError(.badURL)
        }

        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            print("Host fetch for: ", host)
            // Reset values
            self.hostTable.host = host
            self.hostTable.dnsLookups.removeAll()

            DNSResolver.resolve(host: host) { error, addresses in
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
                WhoisXml.whoisQuery(host) { error, response in
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

                WhoisXml.query(host, service: .dns) { (error, response: DnsCoordinate?) in
                    guard error == nil else {
                        self.showError("Error getting WHOIS", message: error!.localizedDescription)
                        self.hostTable.whoisRecord = nil
                        return
                    }

                    guard let response = response else {
                        self.showError(message: "No Whois Data")
                        self.hostTable.dnsRecords = nil
                        return
                    }

                    self.hostTable.dnsRecords = response.dnsData.dnsRecords
                }
            }
        }
    }
}
