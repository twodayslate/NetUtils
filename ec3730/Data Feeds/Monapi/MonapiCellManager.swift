//
//  GoogleWebRiskCellManager.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/17/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class MonapiCellManager: CellManager {
    override func askForMoney() {
        if let purchase = self.dataFeed as? DataFeedPurchaseProtocol {
            if !purchase.owned {
                let locked = WhoisLockedTableViewCell(purchase, heading: "Unlock Email, IP & Domain Data",
                                                      subheading: "Identify malicious users, localize IPs, reduce fraud and undesirable signups and so much more")
                locked.iapDelegate = self
                cells = [locked]
            }
        }
    }

    public var currentRecord: MonapiThreat?
    //swiftlint:disable cyclomatic_complexity
    func configure(_ record: MonapiThreat?) {
        stopLoading()
        guard let record = record else {
            return
        }

        currentRecord = record

        cells = []
        
        if let thing = currentRecord?.domain {
            let emailCell = CopyDetailCell(title: "Domain", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.hostname {
            let emailCell = CopyDetailCell(title: "Hostname", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.ip {
            let emailCell = CopyDetailCell(title: "IP", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.mail {
            let emailCell = CopyDetailCell(title: "Mail", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.user {
            let emailCell = CopyDetailCell(title: "User", detail: thing)
            cells.append(emailCell)
        }

        if let blacklist = currentRecord?.blacklist, blacklist.count > 0 {
            let cell = ContactCell(reuseIdentifier: "blacklist", title: "Blacklist")
            for host in blacklist.sorted() {
                cell.addRow(ContactCellRow(title: "", detail: host))
            }
            cells.append(cell)
        }
        
        if let blacklist = currentRecord?.threat_score {
            let cell = ContactCell(reuseIdentifier: "threat", title: "Threat")
            cell.addRow(ContactCellRow(title: "Score", detail: "\(blacklist)"))

            if let thing = currentRecord?.threat_level {
                cell.addRow(ContactCellRow(title: "Level", detail: thing))
            }
            
            if let thing = currentRecord?.threat_class {
                for item in thing {
                    cell.addRow(ContactCellRow(title: "", detail: item))
                }
            }
            cells.append(cell)
        }
        
        if let blacklist = currentRecord?.blacklists, blacklist.count > 0 {
            let cell = ContactCell(reuseIdentifier: "blacklists", title: "Blacklist")
            for host in blacklist.sorted() {
                cell.addRow(ContactCellRow(title: "", detail: host))
            }
            cells.append(cell)
        }
        
        if let blacklist = currentRecord?.mx_blacklist, blacklist.count > 0 {
            let cell = ContactCell(reuseIdentifier: "mx_blacklist", title: "MX Blacklist")
            for host in blacklist {
                if let key = host.first, let value = key.value {
                    cell.addRow(ContactCellRow(title: key.key, detail: value))
                }
            }
            cells.append(cell)
        }
        
        if let blacklist = currentRecord?.ns_blacklist, blacklist.count > 0 {
            let cell = ContactCell(reuseIdentifier: "ns_blacklist", title: "NS Blacklist")
            for host in blacklist {
                if let key = host.first, let value = key.value {
                    cell.addRow(ContactCellRow(title: key.key, detail: value))
                }
            }
            cells.append(cell)
        }

        if let thing = currentRecord?.asn_number {
            let emailCell = CopyDetailCell(title: "ASN Number", detail: "\(thing)")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.asn_organization, !thing.isEmpty {
            let emailCell = CopyDetailCell(title: "ASN Organization", detail: thing)
            cells.append(emailCell)
        }

        if let thing = currentRecord?.is_catchall {
            let emailCell = CopyDetailCell(title: "Catch-all", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.is_proxy {
            let emailCell = CopyDetailCell(title: "Proxy", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.is_free {
            let emailCell = CopyDetailCell(title: "Free", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.is_attacker {
            let emailCell = CopyDetailCell(title: "Attacker", detail: (thing ? "Yes" : "No"))
            cells.append(emailCell)
        }

        if let thing = currentRecord?.is_malware {
            let emailCell = CopyDetailCell(title: "Malware", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.is_tor_exit {
            let emailCell = CopyDetailCell(title: "Tor Exit Node", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.is_role {
            let emailCell = CopyDetailCell(title: "Role", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.is_disposable {
            let emailCell = CopyDetailCell(title: "Disposable", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.disposable {
            let emailCell = CopyDetailCell(title: "Disposable", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.mx_records {
            let emailCell = CopyDetailCell(title: "MX Record", detail: thing ? "Yes" : "No")
            cells.append(emailCell)
        }

        if let thing = currentRecord?.message {
            let emailCell = CopyDetailCell(title: "Message", detail: thing)
            cells.append(emailCell)
        }

        if let thing = currentRecord?.result {
            let emailCell = CopyDetailCell(title: "Result", detail: thing)
            cells.append(emailCell)
        }

        if let smtpServer = currentRecord?.smtp_server {
            let cell = ContactCell(reuseIdentifier: "smtp", title: "SMTP Server")
            cell.addRow(ContactCellRow(title: "Connected", detail: smtpServer ? "Yes" : "No"))

            if let thing = currentRecord?.block {
                cell.addRow(ContactCellRow(title: "", detail: thing ? "Blocked" : "Not Blocked"))
            }

            if let thing = currentRecord?.code {
                cell.addRow(ContactCellRow(title: "Code", detail: "\(thing)"))
            }

            if let thing = currentRecord?.is_catchall {
                cell.addRow(ContactCellRow(title: "Code", detail: thing ? "Yes" : "No"))
            }

            cells.append(cell)
        }

        if let thing = currentRecord?.city {
            let emailCell = CopyDetailCell(title: "City", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.region {
            let emailCell = CopyDetailCell(title: "Region", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.country {
            let emailCell = CopyDetailCell(title: "Country", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.postal {
            let emailCell = CopyDetailCell(title: "Post code", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.timezone {
            let emailCell = CopyDetailCell(title: "Timezone", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.iso_code {
            let emailCell = CopyDetailCell(title: "ISO Country Code", detail: thing)
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.latitude {
            let emailCell = CopyDetailCell(title: "Latitude", detail: "\(thing)")
            cells.append(emailCell)
        }
        
        if let thing = currentRecord?.longitude {
            let emailCell = CopyDetailCell(title: "Longitude", detail: "\(thing)")
            cells.append(emailCell)
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
