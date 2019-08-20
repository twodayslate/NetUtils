//
//  WhoisXmlCells.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/8/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import UIKit

class ContactCellRow: UIStackView {
    var titleLabel: UILabel
    var detailLabel: CopyLabel
    init(title: String, detail: String) {
        titleLabel = UILabel()
        detailLabel = CopyLabel()

        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.adjustsFontSizeToFitWidth = true

        detailLabel.text = detail
        detailLabel.textAlignment = .right
        detailLabel.adjustsFontSizeToFitWidth = true

        addArrangedSubview(titleLabel)
        addArrangedSubview(detailLabel)

        titleLabel.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.25).isActive = true

        let hold = UILongPressGestureRecognizer(target: detailLabel, action: #selector(detailLabel.copyAction(_:)))
        hold.isEnabled = true
        detailLabel.isUserInteractionEnabled = true
        detailLabel.addGestureRecognizer(hold)
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ContactCell: UITableViewCell {
    var titleLabel: UILabel?
    var stack: UIStackView

    init(reuseIdentifier: String?, title: String) {
        stack = UIStackView()
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        stack.spacing = 10.0
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        contentView.addSubview(stack)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))

        titleLabel = UILabel()
        titleLabel?.text = title
        titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)

        stack.addArrangedSubview(titleLabel!)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addRow(_ row: ContactCellRow) {
        stack.addArrangedSubview(row)
    }
}

class WhoisXmlCellManager {
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
            let locked = WhoisLockedTableViewCell(reuseIdentifier: "locked")
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

    var currentRecord: WhoisRecord?

    // swiftlint:disable:next cyclomatic_complexity
    func configure(_ record: WhoisRecord?) {
        stopLoading()

        guard let record = record else {
            return
        }

        currentRecord = record

        let createdCell = CopyDetailCell(title: "Created", detail: "\(record.createdDate ?? record.registryData.createdDate)")
        cells.append(createdCell)

        let updatedCell = CopyDetailCell(title: "Updated", detail: "\(record.updatedDate ?? record.registryData.updatedDate)")
        cells.append(updatedCell)

        let expiresCell = CopyDetailCell(title: "Expires", detail: "\(record.expiresDate ?? record.registryData.expiresDate)")
        cells.append(expiresCell)

        let registrarCell = CopyDetailCell(title: "Registrar", detail: record.registrarName)
        cells.append(registrarCell)

        let idCell = CopyDetailCell(title: "IANAID", detail: record.registrarIANAID)
        cells.append(idCell)

        if let whoisServer = record.whoisServer {
            let whoisServerCell = CopyDetailCell(title: "WHOIS Server", detail: whoisServer)
            cells.append(whoisServerCell)
        }

        let ageCell = CopyDetailCell(title: "Estimated Age", detail: "\(record.estimatedDomainAge) day(s)")
        cells.append(ageCell)

        let emailCell = CopyDetailCell(title: "Contact Email", detail: record.contactEmail)
        cells.append(emailCell)

        let hostNames = record.nameServers?.hostNames ?? record.registryData.nameServers.hostNames
        if hostNames.count > 0 {
            let cell = ContactCell(reuseIdentifier: "hostnames", title: "Host Names")
            for host in hostNames.sorted() {
                cell.addRow(ContactCellRow(title: "", detail: host))
            }
            cells.append(cell)
        }

        var didAddRecord = false
        if let contact = record.registrant {
            didAddRecord = true
            let cell = ContactCell(reuseIdentifier: "registrant", title: "Registrant")
            if let name = contact.name {
                cell.addRow(ContactCellRow(title: "Name", detail: name))
            }

            if let org = contact.organization {
                cell.addRow(ContactCellRow(title: "Organization", detail: org))
            }

            var street: [String] = [String]()
            if let address = contact.street1 {
                street.append(address)
            }
            if let address = contact.street2 {
                street.append(address)
            }
            if let address = contact.street3 {
                street.append(address)
            }
            if let address = contact.street4 {
                street.append(address)
            }
            if street.count > 0 {
                cell.addRow(ContactCellRow(title: "Street", detail: street.joined(separator: "\n")))
            }

            if let city = contact.city {
                cell.addRow(ContactCellRow(title: "City", detail: city))
            }

            if let postCode = contact.postalCode {
                cell.addRow(ContactCellRow(title: "Postal Code", detail: postCode))
            }

            if let state = contact.state {
                cell.addRow(ContactCellRow(title: "State", detail: state))
            }

            cell.addRow(ContactCellRow(title: "Country", detail: contact.country + "(\(contact.countryCode))"))

            if let email = contact.email {
                cell.addRow(ContactCellRow(title: "Email", detail: email))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: phone))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: fax))
            }

            cells.append(cell)
        }

        if !didAddRecord, let contact = record.registryData.regustrant {
            let cell = ContactCell(reuseIdentifier: "admin", title: "Registrant")
            if let name = contact.name {
                cell.addRow(ContactCellRow(title: "Name", detail: name))
            }

            if let org = contact.organization {
                cell.addRow(ContactCellRow(title: "Organization", detail: org))
            }

            var street: [String] = [String]()
            if let address = contact.street1 {
                street.append(address)
            }
            if let address = contact.street2 {
                street.append(address)
            }
            if let address = contact.street3 {
                street.append(address)
            }
            if let address = contact.street4 {
                street.append(address)
            }
            if street.count > 0 {
                cell.addRow(ContactCellRow(title: "Street", detail: street.joined(separator: "\n")))
            }

            if let city = contact.city {
                cell.addRow(ContactCellRow(title: "City", detail: city))
            }

            if let postCode = contact.postalCode {
                cell.addRow(ContactCellRow(title: "Postal Code", detail: postCode))
            }

            if let state = contact.state {
                cell.addRow(ContactCellRow(title: "State", detail: state))
            }

            cells.append(cell)
        }

        didAddRecord = false
        if let contact = record.administrativeContact {
            didAddRecord = true
            let cell = ContactCell(reuseIdentifier: "admin", title: "Administrative Contact")
            if let name = contact.name {
                cell.addRow(ContactCellRow(title: "Name", detail: name))
            }

            if let org = contact.organization {
                cell.addRow(ContactCellRow(title: "Organization", detail: org))
            }

            var street: [String] = [String]()
            if let address = contact.street1 {
                street.append(address)
            }
            if let address = contact.street2 {
                street.append(address)
            }
            if let address = contact.street3 {
                street.append(address)
            }
            if let address = contact.street4 {
                street.append(address)
            }
            if street.count > 0 {
                cell.addRow(ContactCellRow(title: "Street", detail: street.joined(separator: "\n")))
            }

            if let city = contact.city {
                cell.addRow(ContactCellRow(title: "City", detail: city))
            }

            if let postCode = contact.postalCode {
                cell.addRow(ContactCellRow(title: "Postal Code", detail: postCode))
            }

            if let state = contact.state {
                cell.addRow(ContactCellRow(title: "State", detail: state))
            }

            cell.addRow(ContactCellRow(title: "Country", detail: contact.country + "(\(contact.countryCode))"))

            if let email = contact.email {
                cell.addRow(ContactCellRow(title: "Email", detail: email))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: phone))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: fax))
            }

            cells.append(cell)
        }

        if !didAddRecord, let contact = record.registryData.administrativeContact {
            let cell = ContactCell(reuseIdentifier: "admin", title: "Administrative Contact")
            if let name = contact.name {
                cell.addRow(ContactCellRow(title: "Name", detail: name))
            }

            if let org = contact.organization {
                cell.addRow(ContactCellRow(title: "Organization", detail: org))
            }

            var street: [String] = [String]()
            if let address = contact.street1 {
                street.append(address)
            }
            if let address = contact.street2 {
                street.append(address)
            }
            if let address = contact.street3 {
                street.append(address)
            }
            if let address = contact.street4 {
                street.append(address)
            }
            if street.count > 0 {
                cell.addRow(ContactCellRow(title: "Street", detail: street.joined(separator: "\n")))
            }

            if let city = contact.city {
                cell.addRow(ContactCellRow(title: "City", detail: city))
            }

            if let postCode = contact.postalCode {
                cell.addRow(ContactCellRow(title: "Postal Code", detail: postCode))
            }

            if let state = contact.state {
                cell.addRow(ContactCellRow(title: "State", detail: state))
            }

            cell.addRow(ContactCellRow(title: "Country", detail: contact.country + "(\(contact.countryCode))"))

            if let email = contact.email {
                cell.addRow(ContactCellRow(title: "Email", detail: email))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: phone))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: fax))
            }

            cells.append(cell)
        }

        didAddRecord = false
        if let contact = record.technicalContact {
            didAddRecord = true
            let cell = ContactCell(reuseIdentifier: "tech", title: "Technical Contact")
            if let name = contact.name {
                cell.addRow(ContactCellRow(title: "Name", detail: name))
            }

            if let org = contact.organization {
                cell.addRow(ContactCellRow(title: "Organization", detail: org))
            }

            var street: [String] = [String]()
            if let address = contact.street1 {
                street.append(address)
            }
            if let address = contact.street2 {
                street.append(address)
            }
            if let address = contact.street3 {
                street.append(address)
            }
            if let address = contact.street4 {
                street.append(address)
            }
            if street.count > 0 {
                cell.addRow(ContactCellRow(title: "Street", detail: street.joined(separator: "\n")))
            }

            if let city = contact.city {
                cell.addRow(ContactCellRow(title: "City", detail: city))
            }

            if let postCode = contact.postalCode {
                cell.addRow(ContactCellRow(title: "Postal Code", detail: postCode))
            }

            if let state = contact.state {
                cell.addRow(ContactCellRow(title: "State", detail: state))
            }

            cell.addRow(ContactCellRow(title: "Country", detail: contact.country + "(\(contact.countryCode))"))

            if let email = contact.email {
                cell.addRow(ContactCellRow(title: "Email", detail: email))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: phone))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: fax))
            }

            cells.append(cell)
        }

        if let contact = record.registryData.technicalContact {
            let cell = ContactCell(reuseIdentifier: "tech", title: "Technical Contact")
            if let name = contact.name {
                cell.addRow(ContactCellRow(title: "Name", detail: name))
            }

            if let org = contact.organization {
                cell.addRow(ContactCellRow(title: "Organization", detail: org))
            }

            var street: [String] = [String]()
            if let address = contact.street1 {
                street.append(address)
            }
            if let address = contact.street2 {
                street.append(address)
            }
            if let address = contact.street3 {
                street.append(address)
            }
            if let address = contact.street4 {
                street.append(address)
            }
            if street.count > 0 {
                cell.addRow(ContactCellRow(title: "Street", detail: street.joined(separator: "\n")))
            }

            if let city = contact.city {
                cell.addRow(ContactCellRow(title: "City", detail: city))
            }

            if let postCode = contact.postalCode {
                cell.addRow(ContactCellRow(title: "Postal Code", detail: postCode))
            }

            if let state = contact.state {
                cell.addRow(ContactCellRow(title: "State", detail: state))
            }

            cell.addRow(ContactCellRow(title: "Country", detail: contact.country + "(\(contact.countryCode))"))

            if let email = contact.email {
                cell.addRow(ContactCellRow(title: "Email", detail: email))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: phone))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: fax))
            }

            cells.append(cell)
        }

        didAddRecord = false
        if let contact = record.billingContact {
            didAddRecord = true
            let cell = ContactCell(reuseIdentifier: "billing", title: "Billing Contact")
            if let name = contact.name {
                cell.addRow(ContactCellRow(title: "Name", detail: name))
            }

            if let org = contact.organization {
                cell.addRow(ContactCellRow(title: "Organization", detail: org))
            }

            var street: [String] = [String]()
            if let address = contact.street1 {
                street.append(address)
            }
            if let address = contact.street2 {
                street.append(address)
            }
            if let address = contact.street3 {
                street.append(address)
            }
            if let address = contact.street4 {
                street.append(address)
            }
            if street.count > 0 {
                cell.addRow(ContactCellRow(title: "Street", detail: street.joined(separator: "\n")))
            }

            if let city = contact.city {
                cell.addRow(ContactCellRow(title: "City", detail: city))
            }

            if let postCode = contact.postalCode {
                cell.addRow(ContactCellRow(title: "Postal Code", detail: postCode))
            }

            if let state = contact.state {
                cell.addRow(ContactCellRow(title: "State", detail: state))
            }

            cell.addRow(ContactCellRow(title: "Country", detail: contact.country + "(\(contact.countryCode))"))

            if let email = contact.email {
                cell.addRow(ContactCellRow(title: "Email", detail: email))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: phone))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: fax))
            }

            cells.append(cell)
        }

        if !didAddRecord, let contact = record.registryData.billingContact {
            let cell = ContactCell(reuseIdentifier: "billing", title: "Billing Contact")
            if let name = contact.name {
                cell.addRow(ContactCellRow(title: "Name", detail: name))
            }

            if let org = contact.organization {
                cell.addRow(ContactCellRow(title: "Organization", detail: org))
            }

            var street: [String] = [String]()
            if let address = contact.street1 {
                street.append(address)
            }
            if let address = contact.street2 {
                street.append(address)
            }
            if let address = contact.street3 {
                street.append(address)
            }
            if let address = contact.street4 {
                street.append(address)
            }
            if street.count > 0 {
                let streetCell = ContactCellRow(title: "Street", detail: street.joined(separator: "\n"))
                streetCell.detailLabel.numberOfLines = 0
                cell.addRow(streetCell)
            }

            if let city = contact.city {
                cell.addRow(ContactCellRow(title: "City", detail: city))
            }

            if let postCode = contact.postalCode {
                cell.addRow(ContactCellRow(title: "Postal Code", detail: postCode))
            }

            if let state = contact.state {
                cell.addRow(ContactCellRow(title: "State", detail: state))
            }

            cell.addRow(ContactCellRow(title: "Country", detail: contact.country + "(\(contact.countryCode))"))

            if let email = contact.email {
                cell.addRow(ContactCellRow(title: "Email", detail: email))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                cell.addRow(ContactCellRow(title: "Phone", detail: phone))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                cell.addRow(ContactCellRow(title: "Fax", detail: fax))
            }

            cells.append(cell)
        }

        cells.append(CopyDetailCell(title: "Availability", detail: record.domainAvailability))

        let status = record.status ?? record.registryData.status
        let statusRow = CopyDetailCell(title: "Status", detail: status)
        statusRow.detailLabel?.numberOfLines = 0
        statusRow.detailLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        cells.append(statusRow)

        if let customFieldName = record.customField1Name, let customFieldValue = record.customField1Value {
            let customCell = CopyDetailCell(title: customFieldName, detail: customFieldValue)
            cells.append(customCell)
        }

        if let customFieldName = record.customField2Name, let customFieldValue = record.customField2Value {
            let customCell = CopyDetailCell(title: customFieldName, detail: customFieldValue)
            cells.append(customCell)
        }

        if let customFieldName = record.customField3Name, let customFieldValue = record.customField3Value {
            let customCell = CopyDetailCell(title: customFieldName, detail: customFieldValue)
            cells.append(customCell)
        }
    }
}

extension WhoisXmlCellManager: InAppPurchaseUpdateDelegate {
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
