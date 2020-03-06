//
//  DFOneTimePurchase.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

open class OneTimePurchase {
    var identifier: String
    var product: SKProduct?

    private var privatePurchased: Bool = false
    var purchased: Bool {
        return privatePurchased
    }

    init(_ identifier: String) {
        self.identifier = identifier
        retrieveProduct()
        verifyPurchase()
    }

    func purchase(completion block: ((PurchaseResult) -> Void)? = nil) {
        SwiftyStoreKit.purchaseProduct(identifier) { result in
            switch result {
            case let .success(details):
                if details.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(details.transaction)
                    self.verifyPurchase()
                    block?(result)
                    return
                }
                self.verifyPurchase { _ in
                    block?(result)
                }
            default:
                block?(result)
            }
        }
    }

    public func verifyPurchase(completion block: ((Error?) -> Void)? = nil) {
        guard SwiftyStoreKit.localReceiptData != nil else {
            block?(nil)
            return
        }

        let validator = AppleReceiptValidator(service: .production, sharedSecret: ApiKey.inApp.key)

        SwiftyStoreKit.verifyReceipt(using: validator) { result in
            switch result {
            case let .success(receipt):
                // Verify the purchase of a Subscription
                let purchaseResult =
                    SwiftyStoreKit.verifyPurchase(productId: self.identifier, inReceipt: receipt)
                switch purchaseResult {
                case .purchased:
                    self.privatePurchased = true
                default:
                    break
                }
            default:
                break
            }
            block?(nil)
        }
    }

    /// - parameters:
    ///   - block: completion block containing possible errors and/or the
    ///            localized price of the `subscription`
    public func retrieveProduct(completion block: ((Error?) -> Void)? = nil) {
        if product != nil {
            block?(nil)
            return
        }

        SwiftyStoreKit.retrieveProductsInfo([self.identifier]) { result in
            guard result.error == nil else {
                block?(result.error)
                return
            }
            if let product = result.retrievedProducts.first {
                self.product = product
                block?(nil)
            } else if let invalidProductId = result.invalidProductIDs.first {
                block?(DataFeedError.invalidProduct(id: invalidProductId))
            }
        }
    }

    public func restore(completion block: ((RestoreResults) -> Void)? = nil) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            } else {
                print("Nothing to Restore")
            }

            // Update isSubscribed cache
            self.verifyPurchase { _ in
                block?(results)
            }
        }
    }
}

protocol DataFeedOneTimePurchase: DataFeedPurchaseProtocol {
    var oneTime: OneTimePurchase { get }
}

extension DataFeedOneTimePurchase {
    var paid: Bool {
        return self.oneTime.purchased
    }

    var owned: Bool {
        if userKey != nil {
            return true
        }

        return self.paid
    }

    var defaultProduct: SKProduct? {
        guard let product = self.oneTime.product else {
            self.retrieve()
            return nil
        }
        return product
    }

    func restore(completion block: ((RestoreResults) -> Void)? = nil) {
        self.oneTime.restore(completion: block)
    }

    func verify(completion block: ((Error?) -> Void)? = nil) {
        self.oneTime.verifyPurchase(completion: block)
    }

    func retrieve(completion block: ((Error?) -> Void)? = nil) {
        self.oneTime.retrieveProduct(completion: block)
    }
}
