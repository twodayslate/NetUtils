//
//  DataFeedCells.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class DataFeedCells {
    
    var feeds: [DataFeed.Type] {
        return [WhoisXml.self]
    }
    
    var subscriptions: [DataFeedSubscription.Type] {
        return [WhoisXml.self]
    }
    
    var cells: [DataFeedCell] {
        let whoisCell = DataFeedCell(subscriber: WhoisXml.self)
        whoisCell.descriptionText.text = "Unlocks WHOIS and DNS Lookup"
        
        return [whoisCell]
    }
}
