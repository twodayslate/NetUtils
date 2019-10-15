//
//  DataFeedsTableView.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/10/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class DataFeedSubscriptionTableViewController: UITableViewController {
    let subscriber: DataFeed.Type
    let manager: DataFeedSubscriptionCellManager

    init(subscriber: DataFeed.Type) {
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
        
        if let feedCell = manager.cells.first as? DataFeedSubscriptionCell {
            feedCell.subscription.restore() { _ in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
            
            if let sub = self.subscriber as? DataFeedSubscription.Type, sub.paid {
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
        
        let label = UITableViewHeaderFooterView.iapFooter()
        label.delegate = self
        // swiftlint:enable line_length
        return label
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section > 0 {
            let controller = DataFeedUserApiKeyController(subscriber: self.subscriber)
            controller.userApiDelegate = self
            self.navigationController?.present(controller, animated: true, completion: nil)
            return
        }
        if let sub = self.subscriber as? DataFeedSubscription.Type, !sub.owned {
            if let cell = tableView.cellForRow(at: indexPath) as? DataFeedSubscriptionCell {
                // TODO: show loading indicator
                cell.subscription.buy() { _ in
                    // TODO: hide loading indicator
                }
            }
        }
    }
}

extension DataFeedSubscriptionTableViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

extension DataFeedSubscriptionTableViewController: DataFeedUserApiKeyDelegate {
    func didUpdate() {
        self.tableView.reloadData()
    }
}
