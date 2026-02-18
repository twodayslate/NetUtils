//
//  DataFeedPurchaseProtocol.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/17/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

protocol DataFeedPurchaseProtocol: DataFeed {
    var paid: Bool { get }
    var owned: Bool { get }

    var defaultProduct: Product? { get }

    func restore() async throws
    func verify() async
    func retrieve() async
}
