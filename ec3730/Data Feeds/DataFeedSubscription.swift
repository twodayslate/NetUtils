//
//  DataFeedSubscription.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

protocol DataFeedSubscription: DataFeedPurchaseProtocol {
    /// If the API is a paid API or if the user can submit their own API key

    var subscriptions: [Subscription] { get }
}

extension DataFeedSubscription {
    public func restore(completion block: ((RestoreResults) -> Void)? = nil) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            for sub in self.subscriptions {
                sub.restore()
                block?(results)
            }
        }
    }

    public func verifySubscriptions(completion block: ((Error?) -> Void)? = nil) {
        switch subscriptions.count {
        case 0:
            block?(nil)
        case 1:
            subscriptions.first?.verifySubscription { _ in
                block?(nil)
            }
        case 2:
            subscriptions[0].verifySubscription { _ in
                self.subscriptions[1].verifySubscription { _ in
                    block?(nil)
                }
            }
        default:
            for sub in subscriptions {
                sub.verifySubscription()
            }
            block?(nil)
        }
    }
}
