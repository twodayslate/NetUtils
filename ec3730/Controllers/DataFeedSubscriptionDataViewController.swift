//
//  DataFeedsTableView.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/10/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit

class DataFeedSubscriptionTableViewController: UITableViewController {
    let subscriber: DataFeedSubscription.Type
    let manager: DataFeedSubscriptionCellManager
    var iapDelegate: InAppPurchaseUpdateDelegate? = nil
    var userApiUpdateDelegate: DataFeedUserApiKeyDelegate? = nil

    init(subscriber: DataFeedSubscription.Type) {
        self.subscriber = subscriber
        
        manager = DataFeedSubscriptionCellManager(subscriber: self.subscriber)

        super.init(style: .insetGrouped)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.subscriber.name
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restore(_:)))
    }
    
    @objc func restore(_ sender: Any?) {
        SwiftyStoreKit.restorePurchases { results in
            for sub in self.subscriber.subscriptions {
                sub.verifySubscription { _ in
                    self.restoreInAppPurchase(results)
                }
            }
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return manager.cells.count
        default:
            return 1
            
        }
        
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = manager.cells[indexPath.row]
            if (cell as? DataFeedSubscriptionCell)?.subscription.isSubscribed ?? false {
                cell.accessoryType = .checkmark
            }
            
            if self.subscriber.paid {
                cell.detailTextLabel?.text = nil
            }
            return cell
        default:
            break
        }
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "userAPI")
        cell.textLabel?.text = "API Key"
        cell.accessoryType = .disclosureIndicator
        if self.subscriber.userKey == nil {
            cell.detailTextLabel?.text = "Default"
        } else {
            cell.detailTextLabel?.text = "User Provided"
        }
        
        return cell
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section > 0 {
            return nil
        }
        
        if self.subscriber.paid {
            let text = UILabel()
            text.text = "Thank you for your support!"
            text.textAlignment = .center
            text.textColor = UIColor.systemGray
            return text
        }
        
        let footer = IAPFooterView()
        footer.label.delegate = self
        return footer
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section > 0 {
            let controller = DataFeedUserApiKeyController(subscriber: self.subscriber)
            controller.userApiDelegate = self
            self.navigationController?.present(controller, animated: true, completion: nil)
            return
        }
        
        if !self.subscriber.paid {
            if let cell = tableView.cellForRow(at: indexPath) as? DataFeedSubscriptionCell {
                // TODO: show loading indicator
                cell.subscription.buy() { result in
                    self.updatedInAppPurchase(result)
                    // TODO: hide loading indicator
                }
            }
        }
    }
}

extension DataFeedSubscriptionTableViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        self.open(URL, title: "")
        return false
    }
}

// MARK: - DataFeedUserApiKeyDelegate
extension DataFeedSubscriptionTableViewController: DataFeedUserApiKeyDelegate {
    func didUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension DataFeedSubscriptionTableViewController: InAppPurchaseUpdateDelegate {
    func updatedInAppPurchase(_ result: PurchaseResult) {
        self.iapDelegate?.updatedInAppPurchase(result)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func restoreInAppPurchase(_ results: RestoreResults) {
        self.iapDelegate?.restoreInAppPurchase(results)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func verifyInAppSubscription(error: Error?, result: VerifySubscriptionResult?) {
        self.iapDelegate?.verifyInAppSubscription(error: error, result: result)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
