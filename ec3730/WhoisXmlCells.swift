//
//  WhoisXmlCells.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/8/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class WhoisXmlCellManager {
    var cells = [UITableViewCell]()
    
    init() {
        if !WhoisXml.isSubscribed {
            cells = [WhoisLockedTableViewCell()]
        }
    }
    
    func configure(_ record: WhoisRecord?) {
        cells.removeAll()
        guard let record = record else {
            return
        }
        
        let createdCell = UITableViewCell(style: .value1, reuseIdentifier: "created")
        createdCell.textLabel?.text = "Created"
        createdCell.detailTextLabel?.text = "\(record.createdDate ?? record.registryData.createdDate)"
        cells.append(createdCell)
        
        let updatedCell = UITableViewCell(style: .value1, reuseIdentifier: "updated")
        updatedCell.textLabel?.text = "Updated"
        updatedCell.detailTextLabel?.text = "\(record.updatedDate ?? record.registryData.updatedDate)"
        cells.append(updatedCell)
        
        let registrarCell = UITableViewCell(style: .value1, reuseIdentifier: "registrar")
        registrarCell.textLabel?.text = "Registrar"
        registrarCell.detailTextLabel?.text = record.registrarName
        cells.append(registrarCell)
        
        if let whoisServer = record.whoisServer {
            let whoisServerCell = UITableViewCell(style: .value1, reuseIdentifier: "whoisServer")
            whoisServerCell.textLabel?.text = "WHOIS Server"
            whoisServerCell.detailTextLabel?.text = whoisServer
            cells.append(whoisServerCell)
        }
        
        let ageCell = UITableViewCell(style: .value1, reuseIdentifier: "age")
        ageCell.textLabel?.text = "Estimated Age"
        ageCell.detailTextLabel?.text = "\(record.estimatedDomainAge) day(s)"
        cells.append(ageCell)
        
        let emailCell = UITableViewCell(style: .value1, reuseIdentifier: "email")
        emailCell.textLabel?.text = "Contact Email"
        emailCell.detailTextLabel?.text = record.contactEmail
        cells.append(emailCell)
        
        if let customFieldName = record.customField1Name, let customFieldValue = record.customField1Value {
            let customCell = UITableViewCell(style: .value1, reuseIdentifier: "custom")
            customCell.textLabel?.text = customFieldName
            customCell.detailTextLabel?.text = customFieldValue
            cells.append(customCell)
        }
        
        if let customFieldName = record.customField2Name, let customFieldValue = record.customField2Value {
            let customCell = UITableViewCell(style: .value1, reuseIdentifier: "custom")
            customCell.textLabel?.text = customFieldName
            customCell.detailTextLabel?.text = customFieldValue
            cells.append(customCell)
        }
        
        if let customFieldName = record.customField3Name, let customFieldValue = record.customField3Value {
            let customCell = UITableViewCell(style: .value1, reuseIdentifier: "custom")
            customCell.textLabel?.text = customFieldName
            customCell.detailTextLabel?.text = customFieldValue
            cells.append(customCell)
        }
    }
}
