//
//  DataFeedSubscriptionCellManager.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class DataFeedSubscriptionCell: UITableViewCell {
    var subscription: Subscription
    init(_ subscription: Subscription) {
        self.subscription = subscription
        super.init(style: .value1, reuseIdentifier: subscription.identifier)

        textLabel?.text = self.subscription.product?.subscriptionPeriod?.unit.localizedAdjectiveDescription
        detailTextLabel?.text = self.subscription.product?.localizedPrice

        if subscription.isSubscribed {
            accessoryType = .checkmark
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DataFeedOneTimeCell: UITableViewCell {
    var product: OneTimePurchase
    init(_ product: OneTimePurchase) {
        self.product = product
        super.init(style: .value1, reuseIdentifier: product.identifier)

        textLabel?.text = "One-Time Purchase"
        detailTextLabel?.text = self.product.product?.localizedPrice
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DataFeedSubscriptionCellManager {
    let subscriber: DataFeed

    var subscriptionCells = [DataFeedSubscriptionCell]()
    var oneTimePurchaseCell: DataFeedOneTimeCell?

    init(subscriber: DataFeed) {
        self.subscriber = subscriber

        if let subscriptions = self.subscriber as? DataFeedSubscription {
            for (_, sub) in subscriptions.subscriptions.enumerated() {
                subscriptionCells.append(DataFeedSubscriptionCell(sub))
            }
        }

        if let oneTime = self.subscriber as? DataFeedOneTimePurchase {
            oneTimePurchaseCell = DataFeedOneTimeCell(oneTime.oneTime)
        }
    }
}
