//
//  DFSubscription.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

open class Subscription {
    var identifier: String
    var product: SKProduct?

    init(_ identifier: String) {
        self.identifier = identifier
        retrieveProduct()
        verifySubscription()
    }

    public var session = URLSession.shared
    private var cachedExpirationDate: Date?

    /// If the current user has subscribed to the WHOIS API
    /// - Important:
    /// This will give you the cached version, use `verifySubscription` to get the asyncronous version
    public var isSubscribed: Bool {
        #if DEBUG
            if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
                return true
            }
        #endif

        guard let expiration = cachedExpirationDate else {
            verifySubscription()
            return false
        }

        let state = expiration.timeIntervalSinceNow > 0

        if !state {
            verifySubscription()
        }

        return state
    }

    /// - parameters:
    ///   - block: completion block containing possible errors and/or the
    ///            localized price of the `subscription`
    public func retrieveProduct(completion block: ((Error?) -> Void)? = nil) {
        if product != nil {
            block?(nil)
            return
        }

        SwiftyStoreKit.retrieveProductsInfo([identifier]) { result in
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

    public func verifySubscription(completion block: ((Error?) -> Void)? = nil) {
        guard SwiftyStoreKit.localReceiptData != nil else {
            block?(nil)
            return
        }

        let validator = AppleReceiptValidator(service: .production, sharedSecret: ApiKey.inApp.key)

        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                _ = receiptData.base64EncodedString(options: [])

                // Add code to read receiptData...
            } catch {
                print("Couldn't read receipt data: " + error.localizedDescription)
            }
        }

        SwiftyStoreKit.verifyReceipt(using: validator) { result in
            switch result {
            case let .success(receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: Set([self.identifier]),
                                                                        inReceipt: receipt)
                switch purchaseResult {
                case let .purchased(expiryDate, _):
                    print("subscription is valid until \(expiryDate)\n")
                    self.cachedExpirationDate = expiryDate
                case let .expired(expiryDate, _):
                    print("subscription is expired since \(expiryDate)")
                case .notPurchased:
                    print("The user has never purchased subscription")
                }
                block?(nil)
            case let .error(error):
                print("Receipt verification failed: \(error)")
                block?(error)
            }
        }
    }

    public func buy(completion block: ((PurchaseResult) -> Void)? = nil) {
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: true, simulatesAskToBuyInSandbox: false) { result in

            switch result {
            case let .success(product):
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            default:
                break
            }

            // Update isSubscribed cache
            self.verifySubscription { _ in
                block?(result)
            }
        }
    }

    public func restore(completion block: ((RestoreResults) -> Void)? = nil) {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases where purchase.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            SwiftyStoreKit.restorePurchases(atomically: true) { results in
                if !results.restoreFailedPurchases.isEmpty {
                    print("Restore Failed: \(results.restoreFailedPurchases)")
                } else if !results.restoredPurchases.isEmpty {
                    print("Restore Success: \(results.restoredPurchases)")
                } else {
                    print("Nothing to Restore")
                }

                // Update isSubscribed cache
                self.verifySubscription { _ in
                    block?(results)
                }
            }
        }
    }
}
