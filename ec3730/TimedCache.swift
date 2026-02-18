//
//  TimedCache.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

class TimedCache {
    var expirationInterval: TimeInterval
    private var data = [String: Any?]()

    init(expiresIn interval: TimeInterval) {
        expirationInterval = interval
    }

    func add(_ object: Any?, for key: String) {
        data[key] = object
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: self.expirationInterval, repeats: false) { _ in
                self.data.removeValue(forKey: key)
            }
        }
    }

    func value<T>(for key: String) -> T? {
        guard let value = data[key] as? T else {
            return nil
        }

        // XXX: invalidate and update the timer?

        return value
    }
}
