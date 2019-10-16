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
    public var iapDelegate: InAppPurchaseUpdateDelegate?

    internal var privateIsLoading: Bool = false
    public var isLoading: Bool {
        return privateIsLoading
    }

    init() {
        cells.append(LoadingCell(reuseIdentifier: "loading"))
        
        WhoisXml.verifySubscriptions { error in
            self.verifyInAppSubscription(error: error, result: nil)
        }
    }

    open func askForMoney() {
        fatalError("Must override")
    }

    open func startLoading() {
        privateIsLoading = true
        if WhoisXml.owned {
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
        if WhoisXml.owned {
            cells.removeAll()
        } else {
            askForMoney()
        }
    }
}

extension CellManager: InAppPurchaseUpdateDelegate {
    public func restoreInAppPurchase(_ results: RestoreResults) {
        if WhoisXml.owned {
            cells.removeAll()
        }

        iapDelegate?.restoreInAppPurchase(results)
    }

    public func updatedInAppPurchase(_ result: PurchaseResult) {
        switch result {
        case .success:
            if WhoisXml.owned {
                cells.removeAll()
            }
        default:
            break
        }

        iapDelegate?.updatedInAppPurchase(result)
    }

    public func verifyInAppSubscription(error: Error?, result: VerifySubscriptionResult?) {
        if WhoisXml.owned {
            cells.removeAll()
        } else {
            askForMoney()
        }

        iapDelegate?.verifyInAppSubscription(error: error, result: result)
    }
}
