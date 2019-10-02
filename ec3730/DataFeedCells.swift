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

        let cell = DataFeedCell("Whois XML API", subscriber: WhoisXml.self)
        cells = [cell]
    }

    override func askForMoney() {
        return
    }

    override func startLoading() {
        for cell in cells {
            let indicator = UIActivityIndicatorView()
            if #available(iOS 13.0, *) {
                indicator.style = .medium
            } else {
                indicator.style = .gray
            }
            indicator.startAnimating()
            cell.accessoryView = indicator
        }
    }

    override func stopLoading() {
        for cell in cells {
            if let cell = cell as? DataFeedCell {
                if cell.owned {
                    cell.accessoryType = .checkmark
                } else {
                    cell.detailTextLabel?.text = "$0.99/month" // XXX: replace with actual price
                }
            } else {
                cell.accessoryType = .none
            }
        }
    }
}
