//
//  InAppPurchaseUpdateDelegate.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit

public protocol InAppPurchaseUpdateDelegate {
    func updatedInAppPurchase(_ result: PurchaseResult)
    func restoreInAppPurchase(_ results: RestoreResults)
    func verifyInAppSubscription(error: Error?, result: VerifySubscriptionResult?)
}

public protocol InAppPurchaseAttemptDelegate {
    func purchaseAttempted()
    func restoreAttempted()
}
