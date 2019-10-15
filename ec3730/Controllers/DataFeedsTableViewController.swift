//
//  DataFeedsTableView.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/10/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class DataFeedsTableViewController: UITableViewController {
    let dataFeeds = DataFeedCells()

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataFeeds.cells.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataFeeds.cells[indexPath.row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Data Feeds"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restore(_:)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dataFeeds.startLoading()
    }
    
    @objc func restore(_ sender: Any?) {
        
        if let feedCell = dataFeeds.cells.first as? DataFeedCell, let sub = feedCell.subscriber as? DataFeedSubscription.Type {
            sub.restore() { _ in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        
        let label = UITableViewHeaderFooterView.iapFooter()
        label.delegate = self
        // swiftlint:enable line_length
        return label
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DataFeedCell {
            let controller = DataFeedSubscriptionTableViewController(subscriber: cell.subscriber)
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
        UIApplication.shared.open(URL)
        return false
    }
}
