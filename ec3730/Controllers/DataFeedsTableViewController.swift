//
//  DataFeedsTableViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/10/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
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

        refreshPurchaseState()
    }

    @objc func restore(_: Any?) {
        Task {
            var firstError: Error?
            for purchase in dataFeeds.purchases {
                do {
                    try await purchase.restore()
                } catch {
                    if firstError == nil {
                        firstError = error
                    }
                }
            }
            await MainActor.run {
                self.tableView.reloadData()
                if let firstError {
                    self.alert(with: firstError)
                }
            }
        }
    }

    private func refreshPurchaseState() {
        Task {
            for purchase in dataFeeds.purchases {
                await purchase.retrieve()
                await purchase.verify()
            }
            await MainActor.run {
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let footer = IAPFooterView()
        footer.label.delegate = self
        return footer
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DataFeedCell {
            if let subscriber = cell.subscriber as? DataFeedPurchaseProtocol {
                let controller = DataFeedSubscriptionTableViewController(subscriber: subscriber)
                controller.iapDelegate = self
                controller.userApiUpdateDelegate = self
                navigationController?.pushViewController(controller, animated: true)
            }
        }

        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DataFeedsTableViewController: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        open(URL, title: "")
        return false
    }
}

extension DataFeedsTableViewController: DataFeedInAppPurchaseUpdateDelegate {
    func didUpdateInAppPurchase(_: DataFeed, error: Error?, transaction _: Transaction?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if let error {
                self.alert(with: error)
            }
        }
    }
}

extension DataFeedsTableViewController: DataFeedUserApiKeyDelegate {
    func didUpdateUserApiKey(_: DataFeed) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
