import SwiftUI

class WhoisXmlWhoisSectionModel: HostSectionModel {
    convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.whoisService)
        self.storeModel = StoreKitModel.whois
    }

    func configure(with record: WhoisRecord) {
        DispatchQueue.main.async {
            self.content.removeAll()
            
            if let copyData = try? JSONEncoder().encode(record) {
                self.dataToCopy = String(data: copyData, encoding: .utf8)
            }
                        
            self.content.append(CopyCellView(title: "Created", content: "\(record.createdDate ?? record.registryData.createdDate)"))

            self.content.append(CopyCellView(title: "Updated", content: "\(record.updatedDate ?? record.registryData.updatedDate)"))

            self.content.append(CopyCellView(title: "Expires", content: "\(record.expiresDate ?? record.registryData.expiresDate)"))

            self.content.append(CopyCellView(title: "Registrar", content: record.registrarName))

            self.content.append(CopyCellView(title: "IANAID", content: record.registrarIANAID))

            if let whoisServer = record.whoisServer {
                self.content.append(CopyCellView(title: "WHOIS Server", content: whoisServer))
            }

            self.content.append(CopyCellView(title: "Estimated Age", content: "\(record.estimatedDomainAge) day(s)"))

            self.content.append(CopyCellView(title: "Contact Email", content: record.contactEmail))

            let hostNames = record.nameServers?.hostNames ?? record.registryData.nameServers.hostNames
            if hostNames.count > 0 {
                var cells = [CopyCellRow]()
                for host in hostNames.sorted() {
                    cells.append(CopyCellRow(title: nil, content: host))
                }
                self.content.append(CopyCellView(title: "Host Names", rows: cells))
            }
//
//            var didAddRecord = false
//            if let contact = record.registrant {
//                didAddRecord = true
//                let cell = ContactCell(reuseIdentifier: "registrant", title: "Registrant")
//                if let name = contact.name {
//                    cell.addRow(ContactCellRow(title: "Name", content: name))
//                }
//
//                if let org = contact.organization {
//                    cell.addRow(ContactCellRow(title: "Organization", content: org))
//                }
//
//                var street: [String] = [String]()
//                if let address = contact.street1 {
//                    street.append(address)
//                }
//                if let address = contact.street2 {
//                    street.append(address)
//                }
//                if let address = contact.street3 {
//                    street.append(address)
//                }
//                if let address = contact.street4 {
//                    street.append(address)
//                }
//                if street.count > 0 {
//                    cell.addRow(ContactCellRow(title: "Street", content: street.joined(separator: "\n")))
//                }
//
//                if let city = contact.city {
//                    cell.addRow(ContactCellRow(title: "City", content: city))
//                }
//
//                if let postCode = contact.postalCode {
//                    cell.addRow(ContactCellRow(title: "Postal Code", content: postCode))
//                }
//
//                if let state = contact.state {
//                    cell.addRow(ContactCellRow(title: "State", content: state))
//                }
//
//                cell.addRow(ContactCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))
//
//                if let email = contact.email {
//                    cell.addRow(ContactCellRow(title: "Email", content: email))
//                }
//
//                if var phone = contact.telephone {
//                    if let phoneExt = contact.telephoneEXT {
//                        phone += " \(phoneExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: phone))
//                }
//
//                if var fax = contact.fax {
//                    if let faxExt = contact.faxEXT {
//                        fax += " \(faxExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: fax))
//                }
//
//                cells.append(cell)
//            }
//
//            if !didAddRecord, let contact = record.registryData.regustrant {
//                let cell = ContactCell(reuseIdentifier: "admin", title: "Registrant")
//                if let name = contact.name {
//                    cell.addRow(ContactCellRow(title: "Name", content: name))
//                }
//
//                if let org = contact.organization {
//                    cell.addRow(ContactCellRow(title: "Organization", content: org))
//                }
//
//                var street: [String] = [String]()
//                if let address = contact.street1 {
//                    street.append(address)
//                }
//                if let address = contact.street2 {
//                    street.append(address)
//                }
//                if let address = contact.street3 {
//                    street.append(address)
//                }
//                if let address = contact.street4 {
//                    street.append(address)
//                }
//                if street.count > 0 {
//                    cell.addRow(ContactCellRow(title: "Street", content: street.joined(separator: "\n")))
//                }
//
//                if let city = contact.city {
//                    cell.addRow(ContactCellRow(title: "City", content: city))
//                }
//
//                if let postCode = contact.postalCode {
//                    cell.addRow(ContactCellRow(title: "Postal Code", content: postCode))
//                }
//
//                if let state = contact.state {
//                    cell.addRow(ContactCellRow(title: "State", content: state))
//                }
//
//                cells.append(cell)
//            }
//
//            didAddRecord = false
//            if let contact = record.administrativeContact {
//                didAddRecord = true
//                let cell = ContactCell(reuseIdentifier: "admin", title: "Administrative Contact")
//                if let name = contact.name {
//                    cell.addRow(ContactCellRow(title: "Name", content: name))
//                }
//
//                if let org = contact.organization {
//                    cell.addRow(ContactCellRow(title: "Organization", content: org))
//                }
//
//                var street: [String] = [String]()
//                if let address = contact.street1 {
//                    street.append(address)
//                }
//                if let address = contact.street2 {
//                    street.append(address)
//                }
//                if let address = contact.street3 {
//                    street.append(address)
//                }
//                if let address = contact.street4 {
//                    street.append(address)
//                }
//                if street.count > 0 {
//                    cell.addRow(ContactCellRow(title: "Street", content: street.joined(separator: "\n")))
//                }
//
//                if let city = contact.city {
//                    cell.addRow(ContactCellRow(title: "City", content: city))
//                }
//
//                if let postCode = contact.postalCode {
//                    cell.addRow(ContactCellRow(title: "Postal Code", content: postCode))
//                }
//
//                if let state = contact.state {
//                    cell.addRow(ContactCellRow(title: "State", content: state))
//                }
//
//                cell.addRow(ContactCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))
//
//                if let email = contact.email {
//                    cell.addRow(ContactCellRow(title: "Email", content: email))
//                }
//
//                if var phone = contact.telephone {
//                    if let phoneExt = contact.telephoneEXT {
//                        phone += " \(phoneExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: phone))
//                }
//
//                if var fax = contact.fax {
//                    if let faxExt = contact.faxEXT {
//                        fax += " \(faxExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: fax))
//                }
//
//                cells.append(cell)
//            }
//
//            if !didAddRecord, let contact = record.registryData.administrativeContact {
//                let cell = ContactCell(reuseIdentifier: "admin", title: "Administrative Contact")
//                if let name = contact.name {
//                    cell.addRow(ContactCellRow(title: "Name", content: name))
//                }
//
//                if let org = contact.organization {
//                    cell.addRow(ContactCellRow(title: "Organization", content: org))
//                }
//
//                var street: [String] = [String]()
//                if let address = contact.street1 {
//                    street.append(address)
//                }
//                if let address = contact.street2 {
//                    street.append(address)
//                }
//                if let address = contact.street3 {
//                    street.append(address)
//                }
//                if let address = contact.street4 {
//                    street.append(address)
//                }
//                if street.count > 0 {
//                    cell.addRow(ContactCellRow(title: "Street", content: street.joined(separator: "\n")))
//                }
//
//                if let city = contact.city {
//                    cell.addRow(ContactCellRow(title: "City", content: city))
//                }
//
//                if let postCode = contact.postalCode {
//                    cell.addRow(ContactCellRow(title: "Postal Code", content: postCode))
//                }
//
//                if let state = contact.state {
//                    cell.addRow(ContactCellRow(title: "State", content: state))
//                }
//
//                cell.addRow(ContactCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))
//
//                if let email = contact.email {
//                    cell.addRow(ContactCellRow(title: "Email", content: email))
//                }
//
//                if var phone = contact.telephone {
//                    if let phoneExt = contact.telephoneEXT {
//                        phone += " \(phoneExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: phone))
//                }
//
//                if var fax = contact.fax {
//                    if let faxExt = contact.faxEXT {
//                        fax += " \(faxExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: fax))
//                }
//
//                cells.append(cell)
//            }
//
//            didAddRecord = false
//            if let contact = record.technicalContact {
//                didAddRecord = true
//                let cell = ContactCell(reuseIdentifier: "tech", title: "Technical Contact")
//                if let name = contact.name {
//                    cell.addRow(ContactCellRow(title: "Name", content: name))
//                }
//
//                if let org = contact.organization {
//                    cell.addRow(ContactCellRow(title: "Organization", content: org))
//                }
//
//                var street: [String] = [String]()
//                if let address = contact.street1 {
//                    street.append(address)
//                }
//                if let address = contact.street2 {
//                    street.append(address)
//                }
//                if let address = contact.street3 {
//                    street.append(address)
//                }
//                if let address = contact.street4 {
//                    street.append(address)
//                }
//                if street.count > 0 {
//                    cell.addRow(ContactCellRow(title: "Street", content: street.joined(separator: "\n")))
//                }
//
//                if let city = contact.city {
//                    cell.addRow(ContactCellRow(title: "City", content: city))
//                }
//
//                if let postCode = contact.postalCode {
//                    cell.addRow(ContactCellRow(title: "Postal Code", content: postCode))
//                }
//
//                if let state = contact.state {
//                    cell.addRow(ContactCellRow(title: "State", content: state))
//                }
//
//                cell.addRow(ContactCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))
//
//                if let email = contact.email {
//                    cell.addRow(ContactCellRow(title: "Email", content: email))
//                }
//
//                if var phone = contact.telephone {
//                    if let phoneExt = contact.telephoneEXT {
//                        phone += " \(phoneExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: phone))
//                }
//
//                if var fax = contact.fax {
//                    if let faxExt = contact.faxEXT {
//                        fax += " \(faxExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: fax))
//                }
//
//                cells.append(cell)
//            }
//
//            if let contact = record.registryData.technicalContact {
//                let cell = ContactCell(reuseIdentifier: "tech", title: "Technical Contact")
//                if let name = contact.name {
//                    cell.addRow(ContactCellRow(title: "Name", content: name))
//                }
//
//                if let org = contact.organization {
//                    cell.addRow(ContactCellRow(title: "Organization", content: org))
//                }
//
//                var street: [String] = [String]()
//                if let address = contact.street1 {
//                    street.append(address)
//                }
//                if let address = contact.street2 {
//                    street.append(address)
//                }
//                if let address = contact.street3 {
//                    street.append(address)
//                }
//                if let address = contact.street4 {
//                    street.append(address)
//                }
//                if street.count > 0 {
//                    cell.addRow(ContactCellRow(title: "Street", content: street.joined(separator: "\n")))
//                }
//
//                if let city = contact.city {
//                    cell.addRow(ContactCellRow(title: "City", content: city))
//                }
//
//                if let postCode = contact.postalCode {
//                    cell.addRow(ContactCellRow(title: "Postal Code", content: postCode))
//                }
//
//                if let state = contact.state {
//                    cell.addRow(ContactCellRow(title: "State", content: state))
//                }
//
//                cell.addRow(ContactCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))
//
//                if let email = contact.email {
//                    cell.addRow(ContactCellRow(title: "Email", content: email))
//                }
//
//                if var phone = contact.telephone {
//                    if let phoneExt = contact.telephoneEXT {
//                        phone += " \(phoneExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: phone))
//                }
//
//                if var fax = contact.fax {
//                    if let faxExt = contact.faxEXT {
//                        fax += " \(faxExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: fax))
//                }
//
//                cells.append(cell)
//            }
//
//            didAddRecord = false
//            if let contact = record.billingContact {
//                didAddRecord = true
//                let cell = ContactCell(reuseIdentifier: "billing", title: "Billing Contact")
//                if let name = contact.name {
//                    cell.addRow(ContactCellRow(title: "Name", content: name))
//                }
//
//                if let org = contact.organization {
//                    cell.addRow(ContactCellRow(title: "Organization", content: org))
//                }
//
//                var street: [String] = [String]()
//                if let address = contact.street1 {
//                    street.append(address)
//                }
//                if let address = contact.street2 {
//                    street.append(address)
//                }
//                if let address = contact.street3 {
//                    street.append(address)
//                }
//                if let address = contact.street4 {
//                    street.append(address)
//                }
//                if street.count > 0 {
//                    cell.addRow(ContactCellRow(title: "Street", content: street.joined(separator: "\n")))
//                }
//
//                if let city = contact.city {
//                    cell.addRow(ContactCellRow(title: "City", content: city))
//                }
//
//                if let postCode = contact.postalCode {
//                    cell.addRow(ContactCellRow(title: "Postal Code", content: postCode))
//                }
//
//                if let state = contact.state {
//                    cell.addRow(ContactCellRow(title: "State", content: state))
//                }
//
//                cell.addRow(ContactCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))
//
//                if let email = contact.email {
//                    cell.addRow(ContactCellRow(title: "Email", content: email))
//                }
//
//                if var phone = contact.telephone {
//                    if let phoneExt = contact.telephoneEXT {
//                        phone += " \(phoneExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: phone))
//                }
//
//                if var fax = contact.fax {
//                    if let faxExt = contact.faxEXT {
//                        fax += " \(faxExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: fax))
//                }
//
//                cells.append(cell)
//            }
//
//            if !didAddRecord, let contact = record.registryData.billingContact {
//                let cell = ContactCell(reuseIdentifier: "billing", title: "Billing Contact")
//                if let name = contact.name {
//                    cell.addRow(ContactCellRow(title: "Name", content: name))
//                }
//
//                if let org = contact.organization {
//                    cell.addRow(ContactCellRow(title: "Organization", content: org))
//                }
//
//                var street: [String] = [String]()
//                if let address = contact.street1 {
//                    street.append(address)
//                }
//                if let address = contact.street2 {
//                    street.append(address)
//                }
//                if let address = contact.street3 {
//                    street.append(address)
//                }
//                if let address = contact.street4 {
//                    street.append(address)
//                }
//                if street.count > 0 {
//                    let streetCell = ContactCellRow(title: "Street", content: street.joined(separator: "\n"))
//                    streetCell.detailLabel.numberOfLines = 0
//                    cell.addRow(streetCell)
//                }
//
//                if let city = contact.city {
//                    cell.addRow(ContactCellRow(title: "City", content: city))
//                }
//
//                if let postCode = contact.postalCode {
//                    cell.addRow(ContactCellRow(title: "Postal Code", content: postCode))
//                }
//
//                if let state = contact.state {
//                    cell.addRow(ContactCellRow(title: "State", content: state))
//                }
//
//                cell.addRow(ContactCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))
//
//                if let email = contact.email {
//                    cell.addRow(ContactCellRow(title: "Email", content: email))
//                }
//
//                if var phone = contact.telephone {
//                    if let phoneExt = contact.telephoneEXT {
//                        phone += " \(phoneExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Phone", content: phone))
//                }
//
//                if var fax = contact.fax {
//                    if let faxExt = contact.faxEXT {
//                        fax += " \(faxExt)"
//                    }
//
//                    cell.addRow(ContactCellRow(title: "Fax", content: fax))
//                }
//
//                cells.append(cell)
//            }
//
//            cells.append( CopyCellView(title: "Availability", content: record.domainAvailability))
//
//            let status = record.status ?? record.registryData.status
//            let statusRow =  CopyCellView(title: "Status", content: status)
//            statusRow.detailLabel?.numberOfLines = 0
//            statusRow.detailLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
//            cells.append(statusRow)
//
//            if let customFieldName = record.customField1Name, let customFieldValue = record.customField1Value {
//                let customCell =  CopyCellView(title: customFieldName, content: customFieldValue)
//                cells.append(customCell)
//            }
//
//            if let customFieldName = record.customField2Name, let customFieldValue = record.customField2Value {
//                let customCell =  CopyCellView(title: customFieldName, content: customFieldValue)
//                cells.append(customCell)
//            }
//
//            if let customFieldName = record.customField3Name, let customFieldValue = record.customField3Value {
//                let customCell =  CopyCellView(title: customFieldName, content: customFieldValue)
//                cells.append(customCell)
//            }
        }
    }
    
    override func query(url: URL? = nil, completion block: (() -> ())? = nil) {
        guard let host = url?.host else {
            block?()
            return
        }
        
        WhoisXml.whoisService.query(["domain": host]) { (error, response: Coordinate?) in
            print(response.debugDescription)

                defer {
                    block?()
                }
                
                guard error == nil else {
                    // todo show error
                    return
                }

                guard let response = response else {
                    // todo show error
                    return
                }

                self.configure(with: response.whoisRecord)
        }
    }
}
