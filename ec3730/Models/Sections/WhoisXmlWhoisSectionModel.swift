import SwiftUI
import Cache

class WhoisXmlWhoisSectionModel: HostSectionModel {
    convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.whoisService)
        self.storeModel = StoreKitModel.whois
    }

    override func configure(with data: Data) {
        self.content.removeAll()
        self.dataToCopy = nil
        guard let result = try? JSONDecoder().decode(WhoisRecord.self, from: data) else {
            return
        }
        self.configure(with: result)
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

            if let contact = record.registrant {
                var rows = [CopyCellRow]()

                if let name = contact.name {
                    rows.append(CopyCellRow(title: "Name", content: name))
                }

                if let org = contact.organization {
                    rows.append(CopyCellRow(title: "Organization", content: org))
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
                    rows.append(CopyCellRow(title: "Street", content: street.joined(separator: "\n")))
                }

                if let city = contact.city {
                    rows.append(CopyCellRow(title: "City", content: city))
                }

                if let postCode = contact.postalCode {
                    rows.append(CopyCellRow(title: "Postal Code", content: postCode))
                }

                if let state = contact.state {
                    rows.append(CopyCellRow(title: "State", content: state))
                }

                rows.append(CopyCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))

                if let email = contact.email {
                    rows.append(CopyCellRow(title: "Email", content: email))
                }

                if var phone = contact.telephone {
                    if let phoneExt = contact.telephoneEXT {
                        phone += " \(phoneExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: phone))
                }

                if var fax = contact.fax {
                    if let faxExt = contact.faxEXT {
                        fax += " \(faxExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: fax))
                }

                self.content.append(CopyCellView(title: "Registrant", rows: rows))
            } else if let contact = record.registryData.regustrant {
                var rows = [CopyCellRow]()
                
                if let name = contact.name {
                    rows.append(CopyCellRow(title: "Name", content: name))
                }

                if let org = contact.organization {
                    rows.append(CopyCellRow(title: "Organization", content: org))
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
                    rows.append(CopyCellRow(title: "Street", content: street.joined(separator: "\n")))
                }

                if let city = contact.city {
                    rows.append(CopyCellRow(title: "City", content: city))
                }

                if let postCode = contact.postalCode {
                    rows.append(CopyCellRow(title: "Postal Code", content: postCode))
                }

                if let state = contact.state {
                    rows.append(CopyCellRow(title: "State", content: state))
                }

                self.content.append(CopyCellView(title: "Registrant", rows: rows))
            }
            
            if let contact = record.administrativeContact {
                var rows = [CopyCellRow]()
                if let name = contact.name {
                    rows.append(CopyCellRow(title: "Name", content: name))
                }

                if let org = contact.organization {
                    rows.append(CopyCellRow(title: "Organization", content: org))
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
                    rows.append(CopyCellRow(title: "Street", content: street.joined(separator: "\n")))
                }

                if let city = contact.city {
                    rows.append(CopyCellRow(title: "City", content: city))
                }

                if let postCode = contact.postalCode {
                    rows.append(CopyCellRow(title: "Postal Code", content: postCode))
                }

                if let state = contact.state {
                    rows.append(CopyCellRow(title: "State", content: state))
                }

                rows.append(CopyCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))

                if let email = contact.email {
                    rows.append(CopyCellRow(title: "Email", content: email))
                }

                if var phone = contact.telephone {
                    if let phoneExt = contact.telephoneEXT {
                        phone += " \(phoneExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: phone))
                }

                if var fax = contact.fax {
                    if let faxExt = contact.faxEXT {
                        fax += " \(faxExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: fax))
                }

                self.content.append(CopyCellView(title: "Administrative Contact", rows: rows))
            } else if let contact = record.registryData.administrativeContact {
                var rows = [CopyCellRow]()
                if let name = contact.name {
                    rows.append(CopyCellRow(title: "Name", content: name))
                }

                if let org = contact.organization {
                    rows.append(CopyCellRow(title: "Organization", content: org))
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
                    rows.append(CopyCellRow(title: "Street", content: street.joined(separator: "\n")))
                }

                if let city = contact.city {
                    rows.append(CopyCellRow(title: "City", content: city))
                }

                if let postCode = contact.postalCode {
                    rows.append(CopyCellRow(title: "Postal Code", content: postCode))
                }

                if let state = contact.state {
                    rows.append(CopyCellRow(title: "State", content: state))
                }

                rows.append(CopyCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))

                if let email = contact.email {
                    rows.append(CopyCellRow(title: "Email", content: email))
                }

                if var phone = contact.telephone {
                    if let phoneExt = contact.telephoneEXT {
                        phone += " \(phoneExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: phone))
                }

                if var fax = contact.fax {
                    if let faxExt = contact.faxEXT {
                        fax += " \(faxExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: fax))
                }

                self.content.append(CopyCellView(title: "Administrative Contact", rows: rows))
            }
//
            if let contact = record.technicalContact {
                var rows = [CopyCellRow]()
                if let name = contact.name {
                    rows.append(CopyCellRow(title: "Name", content: name))
                }

                if let org = contact.organization {
                    rows.append(CopyCellRow(title: "Organization", content: org))
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
                    rows.append(CopyCellRow(title: "Street", content: street.joined(separator: "\n")))
                }

                if let city = contact.city {
                    rows.append(CopyCellRow(title: "City", content: city))
                }

                if let postCode = contact.postalCode {
                    rows.append(CopyCellRow(title: "Postal Code", content: postCode))
                }

                if let state = contact.state {
                    rows.append(CopyCellRow(title: "State", content: state))
                }

                rows.append(CopyCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))

                if let email = contact.email {
                    rows.append(CopyCellRow(title: "Email", content: email))
                }

                if var phone = contact.telephone {
                    if let phoneExt = contact.telephoneEXT {
                        phone += " \(phoneExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: phone))
                }

                if var fax = contact.fax {
                    if let faxExt = contact.faxEXT {
                        fax += " \(faxExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: fax))
                }

                self.content.append(CopyCellView(title: "Technical Contact", rows: rows))
            } else if let contact = record.registryData.technicalContact {
                var rows = [CopyCellRow]()
                if let name = contact.name {
                    rows.append(CopyCellRow(title: "Name", content: name))
                }

                if let org = contact.organization {
                    rows.append(CopyCellRow(title: "Organization", content: org))
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
                    rows.append(CopyCellRow(title: "Street", content: street.joined(separator: "\n")))
                }

                if let city = contact.city {
                    rows.append(CopyCellRow(title: "City", content: city))
                }

                if let postCode = contact.postalCode {
                    rows.append(CopyCellRow(title: "Postal Code", content: postCode))
                }

                if let state = contact.state {
                    rows.append(CopyCellRow(title: "State", content: state))
                }

                rows.append(CopyCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))

                if let email = contact.email {
                    rows.append(CopyCellRow(title: "Email", content: email))
                }

                if var phone = contact.telephone {
                    if let phoneExt = contact.telephoneEXT {
                        phone += " \(phoneExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: phone))
                }

                if var fax = contact.fax {
                    if let faxExt = contact.faxEXT {
                        fax += " \(faxExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: fax))
                }

                self.content.append(CopyCellView(title: "Technical Contact", rows: rows))
            }
//
            if let contact = record.billingContact {
                var rows = [CopyCellRow]()
                if let name = contact.name {
                    rows.append(CopyCellRow(title: "Name", content: name))
                }

                if let org = contact.organization {
                    rows.append(CopyCellRow(title: "Organization", content: org))
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
                    rows.append(CopyCellRow(title: "Street", content: street.joined(separator: "\n")))
                }

                if let city = contact.city {
                    rows.append(CopyCellRow(title: "City", content: city))
                }

                if let postCode = contact.postalCode {
                    rows.append(CopyCellRow(title: "Postal Code", content: postCode))
                }

                if let state = contact.state {
                    rows.append(CopyCellRow(title: "State", content: state))
                }

                rows.append(CopyCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))

                if let email = contact.email {
                    rows.append(CopyCellRow(title: "Email", content: email))
                }

                if var phone = contact.telephone {
                    if let phoneExt = contact.telephoneEXT {
                        phone += " \(phoneExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: phone))
                }

                if var fax = contact.fax {
                    if let faxExt = contact.faxEXT {
                        fax += " \(faxExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: fax))
                }

                self.content.append(CopyCellView(title: "Billing Contact", rows: rows))
            } else if let contact = record.registryData.billingContact {
                var rows = [CopyCellRow]()
                if let name = contact.name {
                    rows.append(CopyCellRow(title: "Name", content: name))
                }

                if let org = contact.organization {
                    rows.append(CopyCellRow(title: "Organization", content: org))
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
                    let streetCell = CopyCellRow(title: "Street", content: street.joined(separator: "\n"))
                    rows.append(streetCell)
                }

                if let city = contact.city {
                    rows.append(CopyCellRow(title: "City", content: city))
                }

                if let postCode = contact.postalCode {
                    rows.append(CopyCellRow(title: "Postal Code", content: postCode))
                }

                if let state = contact.state {
                    rows.append(CopyCellRow(title: "State", content: state))
                }

                rows.append(CopyCellRow(title: "Country", content: contact.country + "(\(contact.countryCode))"))

                if let email = contact.email {
                    rows.append(CopyCellRow(title: "Email", content: email))
                }

                if var phone = contact.telephone {
                    if let phoneExt = contact.telephoneEXT {
                        phone += " \(phoneExt)"
                    }

                    rows.append(CopyCellRow(title: "Phone", content: phone))
                }

                if var fax = contact.fax {
                    if let faxExt = contact.faxEXT {
                        fax += " \(faxExt)"
                    }

                    rows.append(CopyCellRow(title: "Fax", content: fax))
                }

                self.content.append(CopyCellView(title: "Billing Contact", rows: rows))
            }

            self.content.append( CopyCellView(title: "Availability", content: record.domainAvailability))

            let status = record.status ?? record.registryData.status
            self.content.append(CopyCellView(title: "Status", content: status))

            if let customFieldName = record.customField1Name, let customFieldValue = record.customField1Value {
                let customCell =  CopyCellView(title: customFieldName, content: customFieldValue)
                self.content.append(customCell)
            }

            if let customFieldName = record.customField2Name, let customFieldValue = record.customField2Value {
                let customCell =  CopyCellView(title: customFieldName, content: customFieldValue)
                self.content.append(customCell)
            }

            if let customFieldName = record.customField3Name, let customFieldValue = record.customField3Value {
                let customCell =  CopyCellView(title: customFieldName, content: customFieldValue)
                self.content.append(customCell)
            }
        }
    }
    
    
    private let cache = MemoryStorage<String, WhoisRecord>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))
    
    override func query(url: URL? = nil, completion block: (() -> ())? = nil) {
        self.dataToCopy = nil
        self.content.removeAll()
    
        guard let host = url?.host else {
            block?()
            return
        }

        if let record = try? cache.object(forKey: host) {
            self.configure(with: record)
            block?()
            return
        }
        
        guard (self.dataFeed.userKey != nil || self.storeModel?.owned ?? false) else {
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
                self.cache.setObject(response.whoisRecord, forKey: host)
                self.configure(with: response.whoisRecord)
        }
    }
}
