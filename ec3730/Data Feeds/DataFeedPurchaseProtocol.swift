//
//  DataFeedPurchaseProtocol.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/17/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

protocol DataFeedPurchaseProtocol: DataFeed {
    var paid: Bool { get }
    var owned: Bool { get }

    var defaultProduct: SKProduct? { get }

    func restore(completion block: ((RestoreResults) -> Void)?)
    func verify(completion block: ((Error?) -> Void)?)
    func retrieve(completion block: ((Error?) -> Void)?)
}
