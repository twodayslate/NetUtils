//
//  GoogleWebRiskCellManager.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/17/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class GoogleWebRiskCellManager: CellManager {
    override func askForMoney() {
        if let purchase = self.dataFeed as? DataFeedPurchaseProtocol {
            if !purchase.owned {
                let locked = WhoisLockedTableViewCell(purchase, heading: "Unlock Google Web Risk Detection", subheading: "Detect malicious URLs and unsafe web resources")
                locked.iapDelegate = self
                cells = [locked]
            }
        }
    }

    public var currentRecord: GoogleWebRiskRecordWrapper?
    func configure(_ record: GoogleWebRiskRecordWrapper?) {
        stopLoading()
        guard let record = record else {
            return
        }

        currentRecord = record

        cells = []

        if let threats = currentRecord?.threat {
            for threat in threats.threatTypes {
                let cell = UITableViewCell(style: .default, reuseIdentifier: threat.rawValue)
                cell.textLabel?.text = threat.description
                cells.append(cell)
            }
        } else {
            let noRisks = UITableViewCell(style: .default, reuseIdentifier: "no_risks")
            noRisks.textLabel?.text = "No risks detected"
            cells.append(noRisks)
        }
    }

    override func reload() {
        if let prod = self.dataFeed as? DataFeedPurchaseProtocol {
            if prod.owned {
                configure(currentRecord)
            } else {
                askForMoney()
            }
        }
    }
}
