//
//  InAppPurchaseUpdateDelegate.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit

protocol DataFeedInAppPurchaseUpdateDelegate {
    func didUpdateInAppPurchase(_ for: DataFeed, error: Error?, purchaseResult: PurchaseResult?, restoreResults: RestoreResults?, verifySubscriptionResult: VerifySubscriptionResult?, verifyPurchaseResult: VerifyPurchaseResult?, retrieveResults: RetrieveResults?)
}
