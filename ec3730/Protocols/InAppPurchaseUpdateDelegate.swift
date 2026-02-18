//
//  InAppPurchaseUpdateDelegate.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

protocol DataFeedInAppPurchaseUpdateDelegate {
    func didUpdateInAppPurchase(_ for: DataFeed, error: Error?, transaction: Transaction?)
}
