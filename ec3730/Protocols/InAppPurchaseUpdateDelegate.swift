//
//  InAppPurchaseUpdateDelegate.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit

protocol InAppPurchaseUpdateDelegate {
    func updatedInAppPurchase(_ result: PurchaseResult)
    func restoreInAppPurchase(_ results: RestoreResults)
}
