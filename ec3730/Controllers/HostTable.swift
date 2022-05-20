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

class CollapseButton: UIButton {
    var manager: CellManager? {
        didSet {
            setToggleImage()
        }
    }

    var sectionIndex: Int?

    func setToggleImage() {
        guard let manager = manager else {
            return
        }

        if manager.isCollapsed {
            setImage(UIImage(systemName: "arrowtriangle.up.fill"), for: .normal)
        } else {
            setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: .normal)
        }
    }

    func toggle() {
        guard let manager = manager else {
            return
        }

        manager.isCollapsed = !manager.isCollapsed

        setToggleImage()
    }
}

class HostTable: UITableViewController {
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

    @available(*, unavailable)
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
            if whoisManger.isCollapsed {
                return 0
            }
            return whoisManger.cells.count // WHOIS
        case 2:
            if dnsManager.isCollapsed {
                return 0
            }
            return dnsManager.cells.count
        case 3:
            if webRiskManager.isCollapsed {
                return 0
            }
            return webRiskManager.cells.count
        default:
            return 0
        }
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 55.0 // I want this to be dynamic, UITableView.automaticDimension doesn't work
    }

    override func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
//        view.layoutMargins = .init(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        view.backgroundColor = .systemGray4

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true

        let title = UILabel()
        title.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize))
        title.adjustsFontForContentSizeCategory = true
        title.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(title)

        let collapse = CollapseButton(type: .system)
        collapse.contentHorizontalAlignment = .right
        collapse.translatesAutoresizingMaskIntoConstraints = false
        collapse.addTarget(self, action: #selector(collapse(_:)), for: .touchUpInside)
        collapse.sectionIndex = section

        if section != 0 {
            stack.addArrangedSubview(collapse)
        }

        switch section {
        case 0:
            title.text = "Simple IP Lookup"
        case 1:
            title.text = "WHOIS"
            collapse.manager = whoisManger
        case 2:
            title.text = "DNS"
            collapse.manager = dnsManager
        case 3:
            title.text = "Web Risk"
            collapse.manager = webRiskManager
        default:
            break
        }

        return view
    }

    @objc func collapse(_ sender: CollapseButton?) {
        sender?.toggle()
        guard let index = sender?.sectionIndex else {
            return
        }
        tableView.reloadSections(IndexSet(integer: index), with: .automatic)
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 5
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?

        switch indexPath.section {
        case 0:
            if isLoading || dnsLookups.count <= indexPath.row {
                cell = LoadingCell()
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

    func didUpdateInAppPurchase(_ feed: DataFeed, error: Error?, purchaseResult: PurchaseResult?, restoreResults: RestoreResults?, verifySubscriptionResult _: VerifySubscriptionResult?, verifyPurchaseResult _: VerifyPurchaseResult?, retrieveResults _: RetrieveResults?) {
        guard error == nil else {
            // Only show error if user purchased or restored
            if purchaseResult != nil {
                parent?.showError("Error", message: "Unable to verify purchase, please try agian.")
            }

            if restoreResults != nil {
                parent?.showError("Error", message: "Unable to restore, please try agian.")
            }

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
