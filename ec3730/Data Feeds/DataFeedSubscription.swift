//
//  DataFeedSubscription.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

protocol DataFeedSubscription: DataFeedPurchaseProtocol {
    var subscriptions: [Subscription] { get }
}

extension DataFeedSubscription {
    public func restore() async throws {
        try await AppStore.sync()
        await verifySubscriptions()
    }

    public func verifySubscriptions() async {
        for sub in subscriptions {
            await sub.verifySubscription()
        }
    }
}
