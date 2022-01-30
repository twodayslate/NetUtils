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
    var feeds: [DataFeed] {
        return [WhoisXml.current, GoogleWebRisk.current]
    }

    var subscriptions: [DataFeedSubscription] {
        // swiftlint:disable:next force_cast
        return feeds.filter { $0 is DataFeedSubscription } as! [DataFeedSubscription]
    }

    var oneTimes: [DataFeedOneTimePurchase] {
        // swiftlint:disable:next force_cast
        return feeds.filter { $0 is DataFeedOneTimePurchase } as! [DataFeedOneTimePurchase]
    }

    var purchases: [DataFeedPurchaseProtocol] {
        // swiftlint:disable:next force_cast
        return feeds.filter { $0 is DataFeedPurchaseProtocol } as! [DataFeedPurchaseProtocol]
    }

    var cells: [DataFeedCell] {
        let whoisCell = DataFeedCell(subscriber: WhoisXml.current)
        whoisCell.descriptionText.text = "Unlocks WHOIS and DNS Lookup"

        let webRisk = DataFeedCell(subscriber: GoogleWebRisk.current)
        webRisk.descriptionText.text = "Unlocks detection of malicious URLs"

        return [whoisCell, webRisk]
    }
}
