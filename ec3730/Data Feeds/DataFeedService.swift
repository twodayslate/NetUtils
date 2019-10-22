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
    var totalUsage: Int { get }
    var services: [Service] { get }
}

extension DataFeedService {
    func clearUsage(completion block: (() -> Void)? = nil) {
        services.forEach { $0.clearUsage(completion: block) }
    }

    var totalUsage: Int {
        return services.reduce(0) { $0 + $1.usage }
    }

    var usageToday: Int {
        return services.reduce(0) { $0 + $1.usageToday }
    }

    var usageThisMonth: Int {
        return services.reduce(0) { $0 + $1.usageMonth }
    }

    var usageThisYear: Int {
        return services.reduce(0) { $0 + $1.usageYear }
    }
}
