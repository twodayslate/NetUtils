//
//  DataFeedCells.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class DataFeedCells: CellManager {
    override init() {
        super.init()

        let whoisCell = DataFeedCell(subscriber: WhoisXml.self)
        whoisCell.descriptionText.text = "Unlocks WHOIS and DNS Lookup"

        cells = [whoisCell]
    }

    override func askForMoney() {
        return
    }

    override func startLoading() {
        for cell in cells {
            if let cell = cell as? DataFeedCell {
                cell.reload()
            }
        }
    }

    override func stopLoading() {}
}
