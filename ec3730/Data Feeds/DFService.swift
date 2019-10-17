//
//  DFService.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

protocol Service: AnyObject {
    var name: String { get }
    func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint?

    func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?)
}
