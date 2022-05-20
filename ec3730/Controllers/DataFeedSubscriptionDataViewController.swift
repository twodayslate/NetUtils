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

class DataFeedSubscriptionTableViewController: UITableViewController {
    let subscriber: DataFeed
    let manager: DataFeedSubscriptionCellManager
    var iapDelegate: DataFeedInAppPurchaseUpdateDelegate?
    var userApiUpdateDelegate: DataFeedUserApiKeyDelegate?

    init(subscriber: DataFeed) {
        self.subscriber = subscriber

        manager = DataFeedSubscriptionCellManager(subscriber: self.subscriber)

        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = subscriber.name

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restore(_:)))
    }

    @objc func restore(_: Any?) {
        if let purchase = subscriber as? DataFeedPurchaseProtocol {
            purchase.restore { results in
                // swiftlint:disable:next line_length
                self.didUpdateInAppPurchase(self.subscriber, error: nil, purchaseResult: nil, restoreResults: results, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
            }
        }
    }

    var hasUsage: Bool {
        if let serviceSubscriber = subscriber as? DataFeedService {
            if serviceSubscriber.totalUsage > 0 {
                return true
            }
        }
        return false
    }

    var subscriptionIndex = -1
    var oneTimeIndex = -1
    var usageIndex = -1

    override func numberOfSections(in _: UITableView) -> Int {
        var count = 0

        if manager.subscriptionCells.count > 1 {
            subscriptionIndex = count
            count += 1
        }

        if manager.oneTimePurchaseCell != nil {
            oneTimeIndex = count
            count += 1
        }

        if hasUsage {
            usageIndex = count
            count += 1
        }

        count += 1 // API key

        return count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == subscriptionIndex {
            return manager.subscriptionCells.count
        }

        if section == usageIndex {
            // want today, month, year, total, clear
            return 5
        }

        return 1
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == subscriptionIndex {
            let cell = manager.subscriptionCells[indexPath.row]

            // hide price if the user alerady paid for this product
            if (subscriber as? DataFeedPurchaseProtocol)?.paid ?? false {
                cell.detailTextLabel?.text = nil
            }

            return cell
        }

        if indexPath.section == oneTimeIndex, let cell = manager.oneTimePurchaseCell {
            if (subscriber as? DataFeedPurchaseProtocol)?.paid ?? false {
                cell.detailTextLabel?.text = nil
            }

            return cell
        }

        if indexPath.section == usageIndex {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "usage")
            cell.detailTextLabel?.text = "-"
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Past Day"
                if let total = (subscriber as? DataFeedService)?.usageToday {
                    cell.detailTextLabel?.text = "\(total)"
                }
            case 1:
                cell.textLabel?.text = "Past month"
                if let total = (subscriber as? DataFeedService)?.usageThisMonth {
                    cell.detailTextLabel?.text = "\(total)"
                }
            case 2:
                cell.textLabel?.text = "Past Year"
                if let total = (subscriber as? DataFeedService)?.usageThisYear {
                    cell.detailTextLabel?.text = "\(total)"
                }
            case 3:
                cell.textLabel?.text = "Total"
                if let total = (subscriber as? DataFeedService)?.totalUsage {
                    cell.detailTextLabel?.text = "\(total)"
                }
            default:
                let center = CenterTextTableViewCell()
                center.centerLabel.text = "Clear"
                center.centerLabel.textColor = tableView.tintColor
                return center
            }
            return cell
        }

        let cell = UITableViewCell(style: .value1, reuseIdentifier: "userAPI")
        cell.textLabel?.text = "API Key"
        cell.accessoryType = .disclosureIndicator
        if subscriber.userKey == nil {
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
        // No footer for API key
        if section == tableView.numberOfSections - 1 {
            return nil
        }

        let thankYou = UILabel()
        thankYou.text = "Thank you for your support!"
        thankYou.textAlignment = .center
        thankYou.textColor = UIColor.systemGray

        if section == subscriptionIndex, let subscription = subscriber as? DataFeedSubscription {
            if subscription.paid {
                return thankYou
            } else {
                let footer = IAPFooterView()
                footer.label.delegate = self
                return footer
            }
        }

        if section == oneTimeIndex, let oneTime = subscriber as? DataFeedOneTimePurchase, oneTime.oneTime.purchased {
            return thankYou
        }

        return nil
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == usageIndex {
            return "Usage"
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == tableView.numberOfSections - 1 {
            let controller = DataFeedUserApiKeyController(subscriber: subscriber)
            controller.userApiDelegate = self
            navigationController?.present(controller, animated: true, completion: nil)
            return
        }

        if let serv = (subscriber as? DataFeedService), indexPath.section == usageIndex {
            serv.clearUsage {
                DispatchQueue.main.async {
                    self.usageIndex = -1
                    self.tableView.reloadData()
                }
            }
        }

        if !((subscriber as? DataFeedPurchaseProtocol)?.paid ?? true) {
            if let cell = tableView.cellForRow(at: indexPath) as? DataFeedSubscriptionCell {
                // TODO: show loading indicator
                cell.subscription.buy { result in
                    // swiftlint:disable:next line_length
                    self.didUpdateInAppPurchase(self.subscriber, error: nil, purchaseResult: result, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
                    // TODO: hide loading indicator
                }
            }

            if let cell = tableView.cellForRow(at: indexPath) as? DataFeedOneTimeCell {
                cell.product.purchase { result in
                    // swiftlint:disable:next line_length
                    self.didUpdateInAppPurchase(self.subscriber, error: nil, purchaseResult: result, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
                }
                // TODO: show loading indicator
            }
        }
    }
}

extension DataFeedSubscriptionTableViewController: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        open(URL, title: "")
        return false
    }
}

// MARK: - DataFeedUserApiKeyDelegate

extension DataFeedSubscriptionTableViewController: DataFeedUserApiKeyDelegate {
    func didUpdateUserApiKey(_ feed: DataFeed) {
        userApiUpdateDelegate?.didUpdateUserApiKey(feed)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension DataFeedSubscriptionTableViewController: DataFeedInAppPurchaseUpdateDelegate {
    func didUpdateInAppPurchase(_ feed: DataFeed, error: Error?, purchaseResult: PurchaseResult?, restoreResults: RestoreResults?, verifySubscriptionResult: VerifySubscriptionResult?, verifyPurchaseResult: VerifyPurchaseResult?, retrieveResults: RetrieveResults?) {
        // swiftlint:disable:next line_length
        iapDelegate?.didUpdateInAppPurchase(feed, error: error, purchaseResult: purchaseResult, restoreResults: restoreResults, verifySubscriptionResult: verifySubscriptionResult, verifyPurchaseResult: verifyPurchaseResult, retrieveResults: retrieveResults)

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
