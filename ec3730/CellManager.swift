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

        WhoisXml.current.verifySubscriptions { error in
            // swiftlint:disable:next line_length
            self.didUpdateInAppPurchase(self.dataFeed, error: error, purchaseResult: nil, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
        }
    }

    open func askForMoney() {
        fatalError("Must override")
    }

    open func startLoading() {
        privateIsLoading = true
        if WhoisXml.current.owned {
            let cell = LoadingCell(reuseIdentifier: "loading")
            cell.spinner.startAnimating()
            cell.separatorInset.right = .greatestFiniteMagnitude
            cells = [cell]
        } else {
            privateIsLoading = false
            askForMoney()
        }
    }

    open func stopLoading() {
        privateIsLoading = false
        if WhoisXml.current.owned {
            cells.removeAll()
        } else {
            askForMoney()
        }
    }
}

extension CellManager: DataFeedInAppPurchaseUpdateDelegate {
    func didUpdateInAppPurchase(_ feed: DataFeed, error: Error?, purchaseResult: PurchaseResult?, restoreResults: RestoreResults?, verifySubscriptionResult: VerifySubscriptionResult?, verifyPurchaseResult: VerifyPurchaseResult?, retrieveResults: RetrieveResults?) {
        if let sub = feed as? DataFeedSubscription, sub.owned {
            cells.removeAll()
        } else {
            if let one = feed as? DataFeedOneTimePurchase, one.oneTime.purchased || one.userKey != nil {
                cells.removeAll()
            } else {
                askForMoney()
            }
        }

        // swiftlint:disable:next line_length
        iapDelegate?.didUpdateInAppPurchase(feed, error: error, purchaseResult: purchaseResult, restoreResults: restoreResults, verifySubscriptionResult: verifySubscriptionResult, verifyPurchaseResult: verifyPurchaseResult, retrieveResults: retrieveResults)
    }
}
