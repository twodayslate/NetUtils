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

class DataFeedsTableViewController: UITableViewController {
    let dataFeeds = DataFeedCells()

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataFeeds.cells.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataFeeds.cells[indexPath.row]
        cell.iapDelegate = self
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Data Feeds"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restore(_:)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func restore(_ sender: Any?) {
        SwiftyStoreKit.restorePurchases { results in
            for sub in self.dataFeeds.subscriptions {
                sub.verifySubscriptions { _ in 
                    self.restoreInAppPurchase(results)
                }
            }
        }
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let footer = IAPFooterView()
        footer.label.delegate = self
        return footer
        
//        let label = UITableViewHeaderFooterView.iapFooter()
//        label.delegate = self
//        // swiftlint:enable line_length
//        return label
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DataFeedCell, let subscriber = cell.subscriber as? DataFeedSubscription.Type {
            let controller = DataFeedSubscriptionTableViewController(subscriber: subscriber)
            controller.iapDelegate = self
            controller.userApiUpdateDelegate = self
            navigationController?.pushViewController(controller, animated: true)
        }

        self.tableView.deselectRow(at: indexPath, animated: true)
//        guard let cell = tableView.cellForRow(at: indexPath) as? DataFeedCell else {
//            return
//        }

        // cell.state = .cost(subscription: WhoisXml.self)
    }
}

extension DataFeedsTableViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.open(URL, title: "")
        return false
    }
}

extension DataFeedsTableViewController: InAppPurchaseUpdateDelegate {
    func updatedInAppPurchase(_ result: PurchaseResult) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func restoreInAppPurchase(_ results: RestoreResults) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func verifyInAppSubscription(error: Error?, result: VerifySubscriptionResult?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - DataFeedUserApiKeyDelegate
extension DataFeedsTableViewController: DataFeedUserApiKeyDelegate {
    func didUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
