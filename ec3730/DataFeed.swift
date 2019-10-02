//
//  DataFeed.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit

protocol DataFeed {
    static var key: ApiKey { get }
    static var owned: Bool { get }
}
