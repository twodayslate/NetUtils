//
//  CellManager.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/20/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import UIKit

open class CellManager {
    public var cells = [UITableViewCell]()
    var iapDelegate: DataFeedInAppPurchaseUpdateDelegate?
    
    var isCollapsed: Bool = false

    internal var privateIsLoading: Bool = false
    public var isLoading: Bool {
        return privateIsLoading
    }

    var dataFeed: DataFeed
    var service: Service

    init(_ feed: DataFeed, service: Service) {
        dataFeed = feed
        self.service = service
        cells.append(LoadingCell())

        if let prod = feed as? DataFeedPurchaseProtocol {
            prod.verify { error in
                self.didUpdateInAppPurchase(self.dataFeed, error: error, purchaseResult: nil, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
            }
        }
    }

    open func askForMoney() {
        fatalError("Must override")
    }

    open func startLoading() {
        privateIsLoading = true

        if let paid = self.dataFeed as? DataFeedPurchaseProtocol {
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

        if let paid = self.dataFeed as? DataFeedPurchaseProtocol {
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
    func didUpdateInAppPurchase(_ feed: DataFeed, error: Error?, purchaseResult: PurchaseResult?, restoreResults: RestoreResults?, verifySubscriptionResult: VerifySubscriptionResult?, verifyPurchaseResult: VerifyPurchaseResult?, retrieveResults: RetrieveResults?) {
        if let paid = self.dataFeed as? DataFeedPurchaseProtocol {
            if paid.owned {
                cells.removeAll()
            } else {
                askForMoney()
            }
        }

        // swiftlint:disable:next line_length
        iapDelegate?.didUpdateInAppPurchase(feed, error: error, purchaseResult: purchaseResult, restoreResults: restoreResults, verifySubscriptionResult: verifySubscriptionResult, verifyPurchaseResult: verifyPurchaseResult, retrieveResults: retrieveResults)
    }
}
