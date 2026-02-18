//
//  CellManager.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/20/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

open class CellManager {
    public var cells = [UITableViewCell]()
    var iapDelegate: DataFeedInAppPurchaseUpdateDelegate?

    var isCollapsed: Bool = false

    var privateIsLoading: Bool = false
    public var isLoading: Bool {
        privateIsLoading
    }

    var dataFeed: DataFeed
    var service: Service

    init(_ feed: DataFeed, service: Service) {
        dataFeed = feed
        self.service = service
        cells.append(LoadingCell())

        if let prod = feed as? DataFeedPurchaseProtocol {
            Task {
                await prod.verify()
                await MainActor.run {
                    self.didUpdateInAppPurchase(self.dataFeed, error: nil, transaction: nil)
                }
            }
        }
    }

    open func askForMoney() {
        fatalError("Must override")
    }

    open func startLoading() {
        privateIsLoading = true

        if let paid = dataFeed as? DataFeedPurchaseProtocol {
            if paid.owned {
                let cell = LoadingCell()
                cell.spinner.startAnimating()
                cell.separatorInset.right = .greatestFiniteMagnitude
                cells = [cell]
            } else {
                privateIsLoading = false
                askForMoney()
            }
        }
    }

    open func stopLoading() {
        privateIsLoading = false

        if let paid = dataFeed as? DataFeedPurchaseProtocol {
            if paid.owned {
                cells.removeAll()
            } else {
                askForMoney()
            }
        }
    }

    open func reload() {
        fatalError("Must override")
    }
}

extension CellManager: DataFeedInAppPurchaseUpdateDelegate {
    func didUpdateInAppPurchase(_ feed: DataFeed, error: Error?, transaction: Transaction?) {
        if let paid = dataFeed as? DataFeedPurchaseProtocol {
            if paid.owned {
                cells.removeAll()
            } else {
                askForMoney()
            }
        }

        iapDelegate?.didUpdateInAppPurchase(feed, error: error, transaction: transaction)
    }
}
