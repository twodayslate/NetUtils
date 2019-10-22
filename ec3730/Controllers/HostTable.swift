//
//  HostTable.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/19/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import UIKit

class HostTable: UITableViewController {
    let lockIcon = UIImage(named: "Lock")

    var isLoading: Bool {
        get {
            return dnsManager.isLoading && whoisManger.isLoading && webRiskManager.isLoading
        }
        set {
            if newValue {
                DispatchQueue.main.async {
                    self.whoisManger.startLoading()
                    self.dnsManager.startLoading()
                    self.webRiskManager.startLoading()
                }
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    public var dnsLookups = Set<String>()

    public var whoisRecord: WhoisRecord? {
        didSet {
            DispatchQueue.main.async {
                self.whoisManger.configure(self.whoisRecord)
                self.tableView.reloadData()
                // self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }

    public var webRiskRecord: GoogleWebRiskRecordWrapper? {
        didSet {
            DispatchQueue.main.async {
                self.webRiskManager.configure(self.webRiskRecord)
                self.tableView.reloadData()
            }
        }
    }

    public var dnsRecords: [DNSRecords]? {
        didSet {
            DispatchQueue.main.async {
                self.dnsManager.configure(self.dnsRecords)
                self.tableView.reloadData()
                // self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            }
        }
    }

    public var whoisManger = WhoisXmlCellManager(WhoisXml.current, service: WhoisXml.whoisService)
    public var dnsManager = WhoisXmlDnsCellManager(WhoisXml.current, service: WhoisXml.dnsService)
    public var webRiskManager = GoogleWebRiskCellManager(GoogleWebRisk.current, service: GoogleWebRisk.lookupService)

    init() {
        super.init(style: .plain)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // swiftlint:disable:next identifier_name
    public var _host: String = "Host"
    public var host: String {
        get {
            return _host
        }
        set {
            _host = newValue
            DispatchQueue.main.async {
                self.title = self.host + " Information"
            }
        }
    }

    override func tableView(_: UITableView, shouldHighlightRowAt _: IndexPath) -> Bool {
        return false
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // show loading cell or ip list
            return isLoading ? 1 : dnsLookups.count
        case 1:
            return whoisManger.cells.count // WHOIS
        case 2:
            return dnsManager.cells.count
        case 3:
            return webRiskManager.cells.count
        default:
            return 0
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Simple IP Lookup"
        case 1:
            return "WHOIS"
        case 2:
            return "DNS"
        case 3:
            return "Web Risk"
        default:
            return nil
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 4
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?

        switch indexPath.section {
        case 0:
            if isLoading || dnsLookups.count <= indexPath.row {
                cell = LoadingCell(reuseIdentifier: "loading")
            } else {
                cell = CopyCell(title: dnsLookups.sorted()[indexPath.row])
            }
        case 1:
            cell = whoisManger.cells[indexPath.row]
        case 2:
            cell = dnsManager.cells[indexPath.row]
        case 3:
            cell = webRiskManager.cells[indexPath.row]
        default:
            return LoadingCell()
        }

        return cell!
    }

//    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge() // https://stackoverflow.com/questions/20809164/uinavigationcontroller-bar-covers-its-uiviewcontrollers-content
        title = host + " Information"
        whoisManger.iapDelegate = self
        dnsManager.iapDelegate = self
        webRiskManager.iapDelegate = self

        // self.tableView.register(WhoisTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(WhoisTableViewCell.self))

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        // self.tableView.separatorInset.left =  self.view.frame.width
        tableView.tableFooterView = UIView() // hide sepeartor

        fetchProducts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fetchProducts()
    }

    func fetchProducts() {
        if !WhoisXml.current.owned, WhoisXml.current.defaultProduct == nil {
            WhoisXml.current.subscriptions[0].retrieveProduct { _ in
                self.reload()
            }
        }

        if !GoogleWebRisk.current.owned, GoogleWebRisk.current.defaultProduct == nil {
            GoogleWebRisk.current.oneTime.retrieveProduct { _ in
                self.reload()
            }
        }
    }
}

extension HostTable: DataFeedInAppPurchaseUpdateDelegate {
    func reload() {
        whoisManger.reload()
        dnsManager.reload()
        webRiskManager.reload()

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func didUpdateInAppPurchase(_ feed: DataFeed, error: Error?, purchaseResult: PurchaseResult?, restoreResults _: RestoreResults?, verifySubscriptionResult _: VerifySubscriptionResult?, verifyPurchaseResult _: VerifyPurchaseResult?, retrieveResults _: RetrieveResults?) {
        guard error == nil else {
            parent?.showError(message: error!.localizedDescription)
            return
        }

        if purchaseResult != nil {
            if let purchase = feed as? DataFeedPurchaseProtocol, purchase.paid {
                parent?.showError("<3", message: "Thank you for your purchase!")
            } else {
                parent?.showError(message: "Unable to verify purchase, please try again.")
            }
        }

        reload()
    }
}
