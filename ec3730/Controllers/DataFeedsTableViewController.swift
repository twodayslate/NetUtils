//
//  DataFeedsTableView.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/10/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import UIKit

class DataFeedsTableViewController: UITableViewController {
    let dataFeeds = DataFeedCells()

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        dataFeeds.cells.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataFeeds.cells[indexPath.row]
        cell.iapDelegate = self
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Data Feeds"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restore(_:)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.reloadData()
    }

    @objc func restore(_: Any?) {
        for purchase in dataFeeds.purchases {
            purchase.restore(completion: { results in
                // This will just reload the table. Might want to do this more smart
                // swiftlint:disable:next line_length
                self.didUpdateInAppPurchase(purchase, error: nil, purchaseResult: nil, restoreResults: results, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
            })
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
        if let cell = tableView.cellForRow(at: indexPath) as? DataFeedCell {
            if let subscriber = cell.subscriber as? DataFeedSubscription ?? cell.subscriber as? DataFeedOneTimePurchase {
                let controller = DataFeedSubscriptionTableViewController(subscriber: subscriber)
                controller.iapDelegate = self
                controller.userApiUpdateDelegate = self
                navigationController?.pushViewController(controller, animated: true)
            }
        }

        self.tableView.deselectRow(at: indexPath, animated: true)
//        guard let cell = tableView.cellForRow(at: indexPath) as? DataFeedCell else {
//            return
//        }

        // cell.state = .cost(subscription: WhoisXml.self)
    }
}

extension DataFeedsTableViewController: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        open(URL, title: "")
        return false
    }
}

extension DataFeedsTableViewController: DataFeedInAppPurchaseUpdateDelegate {
    func didUpdateInAppPurchase(_: DataFeed, error _: Error?, purchaseResult _: PurchaseResult?, restoreResults _: RestoreResults?, verifySubscriptionResult _: VerifySubscriptionResult?, verifyPurchaseResult _: VerifyPurchaseResult?, retrieveResults _: RetrieveResults?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - DataFeedUserApiKeyDelegate

extension DataFeedsTableViewController: DataFeedUserApiKeyDelegate {
    func didUpdateUserApiKey(_: DataFeed) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
