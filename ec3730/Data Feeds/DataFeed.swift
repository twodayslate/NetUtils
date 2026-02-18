//
//  DataFeed.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

protocol DataFeedSingleton: DataFeed {
    static var current: Self { get }
    static var session: URLSession { get }
}

protocol DataFeed: AnyObject {
    var name: String { get }
    var userKey: String? { get set }

    var webpage: URL { get }

    typealias Endpoints = DataFeedEndpoint
}
