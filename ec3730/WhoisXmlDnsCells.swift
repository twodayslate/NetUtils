import Foundation
import SwiftyStoreKit
import UIKit

class WhoisXmlDnsCellManager {
    var cells = [UITableViewCell]()
    var iapDelegate: InAppPurchaseUpdateDelegate?

    init() {
        cells.append(LoadingCell(reuseIdentifier: "loading"))
        WhoisXml.verifySubscription { error, results in
            self.verifyInAppSubscription(error: error, result: results)
        }
    }

    func askForMoney() {
        if !WhoisXml.isSubscribed {
            let locked = WhoisLockedTableViewCell(reuseIdentifier: "dnslocked", heading: "Unlock DNS Lookup", subheading: "Our hosted DNS Lookup provides the records associated with a domain")
            locked.iapDelegate = self
            cells = [locked]
        }
    }

    func startLoading() {
        if WhoisXml.isSubscribed {
            let cell = LoadingCell(reuseIdentifier: "loading")
            cell.spinner.startAnimating()
            cell.separatorInset.right = .greatestFiniteMagnitude
            cells = [cell]
        } else {
            askForMoney()
        }
    }

    func stopLoading() {
        if WhoisXml.isSubscribed {
            cells.removeAll()
        } else {
            askForMoney()
        }
    }

    func configure(_ records: [DNSRecords]?) {
        stopLoading()
        guard let records = records else {
            return
        }

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
}

extension WhoisXmlDnsCellManager: InAppPurchaseUpdateDelegate {
    func restoreInAppPurchase(_ results: RestoreResults) {
        if WhoisXml.isSubscribed {
            cells.removeAll()
        }

        iapDelegate?.restoreInAppPurchase(results)
    }

    func updatedInAppPurchase(_ result: PurchaseResult) {
        switch result {
        case .success:
            if WhoisXml.isSubscribed {
                cells.removeAll()
            }
        default:
            break
        }

        iapDelegate?.updatedInAppPurchase(result)
    }

    func verifyInAppSubscription(error: Error?, result: VerifySubscriptionResult?) {
        if WhoisXml.isSubscribed {
            cells.removeAll()
        } else {
            askForMoney()
        }

        iapDelegate?.verifyInAppSubscription(error: error, result: result)
    }
}
