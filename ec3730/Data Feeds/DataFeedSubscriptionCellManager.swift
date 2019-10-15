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
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DataFeedSubscriptionCellManager: CellManager {
    let subscriber: DataFeed.Type

    init(subscriber: DataFeed.Type) {
        self.subscriber = subscriber
        super.init()

        cells = []

        if let subscriptions = self.subscriber as? DataFeedSubscription.Type {
            for (_, sub) in subscriptions.subscriptions.enumerated() {
                cells.append(DataFeedSubscriptionCell(sub))
            }
        }
    }

    override func askForMoney() {
        return
    }

    override func startLoading() {
        return
    }

    override func stopLoading() {}
}
