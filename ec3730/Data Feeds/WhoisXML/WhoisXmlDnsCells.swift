import Foundation
import SwiftyStoreKit
import UIKit

class WhoisXmlDnsCellManager: CellManager {
    override func askForMoney() {
        if !WhoisXml.current.owned {
            let locked = WhoisLockedTableViewCell(WhoisXml.current, heading: "Unlock DNS Lookup", subheading: "Our hosted DNS Lookup provides the records associated with a domain")
            locked.iapDelegate = self
            cells = [locked]
        }
    }

    public var currentRecords: [DNSRecords]?
    func configure(_ records: [DNSRecords]?) {
        stopLoading()
        guard let records = records else {
            return
        }

        currentRecords = records

        cells = []

        for record in records {
            let cell = ContactCell(reuseIdentifier: record.rawText, title: record.dnsType)
            cell.addRow(ContactCellRow(title: "name", detail: record.name))
            cell.addRow(ContactCellRow(title: "ttl", detail: "\(record.ttl)"))
            cell.addRow(ContactCellRow(title: "RRset Type", detail: "\(record.rRsetType)"))
            if let admin = record.admin {
                cell.addRow(ContactCellRow(title: "Admin", detail: admin))
            }
            if let host = record.host {
                cell.addRow(ContactCellRow(title: "Host", detail: host))
            }
            if let address = record.address {
                cell.addRow(ContactCellRow(title: "Address", detail: address))
            }
            if let strings = record.strings {
                let row = ContactCellRow(title: "Strings", detail: strings.joined(separator: "\n"))
                row.detailLabel.numberOfLines = 0
                row.detailLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                cell.addRow(row)
            }
            if let expire = record.expire {
                cell.addRow(ContactCellRow(title: "Expire", detail: "\(expire)"))
            }
            if let value = record.minimum {
                cell.addRow(ContactCellRow(title: "Minimum", detail: "\(value)"))
            }
            if let value = record.refresh {
                cell.addRow(ContactCellRow(title: "Refresh", detail: "\(value)"))
            }
            if let value = record.retry {
                cell.addRow(ContactCellRow(title: "Retry", detail: "\(value)"))
            }
            if let value = record.serial {
                cell.addRow(ContactCellRow(title: "Serial", detail: "\(value)"))
            }

            cells.append(cell)
        }
    }

    override func reload() {
        if let prod = dataFeed as? DataFeedPurchaseProtocol {
            if prod.owned {
                configure(currentRecords)
            } else {
                askForMoney()
            }
        }
    }
}
