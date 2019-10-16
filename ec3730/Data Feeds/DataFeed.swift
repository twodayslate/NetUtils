//
//  DataFeed.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
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

        guard let expiration = self.cachedExpirationDate else {
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

        SwiftyStoreKit.retrieveProductsInfo([self.identifier]) { result in
            guard result.error == nil else {
                block?(result.error)
                return
            }
            if let product = result.retrievedProducts.first {
                self.product = product
                block?(nil)
            } else if let invalidProductId = result.invalidProductIDs.first {
                block?(WhoisXmlError.invalidProduct(id: invalidProductId))
            }
        }
    }

    public func verifySubscription(completion block: ((Error?) -> Void)? = nil) {
        guard SwiftyStoreKit.localReceiptData != nil else {
            block?(nil)
            return
        }

        let validator = AppleReceiptValidator(service: .production, sharedSecret: ApiKey.inApp.key)

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
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
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

protocol Service: AnyObject {
    var name: String { get }
    func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint?
    func query<T: Decodable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?)
}

protocol DataFeed {
    static var name: String { get }
    static var key: ApiKey { get }
    static var userKey: ApiKey? { get set }

    static var webpage: URL { get }

    typealias Endpoints = DataFeedEndpoint
}

protocol DataFeedSubscription: class, DataFeed {
    /// If the API is a paid API or if the user can submit their own API key
    static var paid: Bool { get }
    static var owned: Bool { get }

    static var subscriptions: [Subscription] { get }
}

/// Support for more than one service for a given Data Feed
protocol DataFeedService: class {
    static var services: [Service] { get }
}

extension DataFeedSubscription {
    public static var currentKey: ApiKey {
        return userKey ?? key
    }
    
    public static func restore(completion block: ((RestoreResults) -> Void)? = nil) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            for sub in Self.subscriptions {
                sub.restore()
                block?(results)
            }
        }
    }
    
    public static func verifySubscriptions(completion block: ((Error?)->Void)? = nil) {

        switch self.subscriptions.count {
        case 0:
            block?(nil)
        case 1:
            self.subscriptions.first?.verifySubscription { _ in
                block?(nil)
            }
        case 2:
            self.subscriptions[0].verifySubscription { _ in
                self.subscriptions[1].verifySubscription { _ in
                    block?(nil)
                }
            }
        default:
            for sub in self.subscriptions {
                sub.verifySubscription()
            }
            block?(nil)
        }
    }
}

open class OneTimePurchase {
    var identifier: String
    
    private var privatePurchased: Bool = false
    var purchased: Bool {
        return privatePurchased
    }
    
    init(_ identifier: String) {
        self.identifier = identifier
        self.verifyPurchase()
    }
    
    func purchase(completion block: ((PurchaseResult)->Void)? = nil) {
        SwiftyStoreKit.purchaseProduct(self.identifier) { result in
            switch result {
            case .success(let details):
                if details.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(details.transaction)
                    self.verifyPurchase()
                    block?(result)
                    return
                }
                self.verifyPurchase()
            default:
                break
            }
            block?(result)
        }
    }
    
    public func verifyPurchase(completion block: (() -> Void)? = nil) {
        guard SwiftyStoreKit.localReceiptData != nil else {
            block?()
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
                case .purchased(_):
                    self.privatePurchased = true
                default:
                    break
                }
            default:
                break
            }
            block?()
        }
    }
}

protocol DataFeedOneTimePurchase: class {
    static var oneTime: OneTimePurchase { get }
}
