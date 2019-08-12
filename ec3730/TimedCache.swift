//
//  TimedCache.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

class TimedCache {
    public var expirationInterval: TimeInterval
    private var data = [String: Any?]()
    
    init(expiresIn interval: TimeInterval) {
        self.expirationInterval = interval
    }
    
    public func add(_ object: Any?, for key: String) {
        self.data[key] = object
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: self.expirationInterval, repeats: false) { timer in
                self.data.removeValue(forKey: key)
            }
        }
    }
    
    public func value<T>(for key: String) -> T? {
        guard let value = data[key] as? T else {
            return nil
        }
        
        // XXX: invalidate and update the timer?
        
        return value
    }
}
