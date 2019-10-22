//
//  DataFeedService.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

/// Support for more than one service for a given Data Feed
protocol DataFeedService: DataFeed {
    var services: [Service] { get }
}
