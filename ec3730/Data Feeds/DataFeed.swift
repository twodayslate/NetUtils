//
//  DataFeed.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

protocol DataFeedSingleton: DataFeed {
    static var current: Self { get }
    static var session: URLSession { get }
}

protocol DataFeed: AnyObject {
    var name: String { get }
    var key: ApiKey { get }
    var userKey: ApiKey? { get set }

    var webpage: URL { get }

    typealias Endpoints = DataFeedEndpoint
}

extension DataFeed {
    public var currentKey: ApiKey {
        return userKey ?? key
    }
}
