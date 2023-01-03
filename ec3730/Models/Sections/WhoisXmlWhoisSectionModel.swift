import Cache
import StoreKit
import SwiftUI

class WhoisXmlWhoisSectionModel: HostSectionModel {
    required convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.whoisService)
        storeModel = StoreKitModel.whois
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        reset()
        let result = try JSONDecoder().decode(WhoisRecord.self, from: data)
        return try configure(with: result)
    }

    @MainActor
    func configure(with record: WhoisRecord) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(record)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let error = record.dataError {
            content.append(.row(title: "Error", content: error))
        }

        content.append(.row(title: "Created", content: "\(record.createdDate ?? record.registryData.createdDate ?? record.audit.createdDate)"))

        content.append(.row(title: "Updated", content: "\(record.updatedDate ?? record.registryData.updatedDate ?? record.audit.updatedDate)"))

        if let expiresDate = record.expiresDate ?? record.registryData.expiresDate {
            content.append(.row(title: "Expires", content: "\(expiresDate)"))
        }

        if let registrarName = record.registrarName {
            content.append(.row(title: "Registrar", content: registrarName))
        }

        if let registrarIANAID = record.registrarIANAID {
            content.append(.row(title: "IANAID", content: registrarIANAID))
        }

        if let whoisServer = record.whoisServer {
            content.append(.row(title: "WHOIS Server", content: whoisServer))
        }

        if let estimatedAge = record.estimatedDomainAge {
            content.append(.row(title: "Estimated Age", content: "\(estimatedAge) day(s)"))
        }

        if let contactEmail = record.contactEmail {
            content.append(.row(title: "Contact Email", content: contactEmail))
        }

        let hostNames = record.nameServers?.hostNames ?? record.registryData.nameServers?.hostNames ?? []
        if !hostNames.isEmpty {
            content.append(.multiple(title: "Host Names", contents: hostNames.sorted().map { .content($0, style: .expandable) }))
        }

        if let contact = record.registrant {
            var rows = [CopyCellType]()

            if let name = contact.name {
                rows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let org = contact.organization {
                rows.append(.row(title: "Organization", content: org, style: .expandable))
            }

            var street = [String]()
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
            if !street.isEmpty {
                rows.append(.row(title: "Street", content: street.joined(separator: "\n"), style: .expandable))
            }

            if let city = contact.city {
                rows.append(.row(title: "City", content: city, style: .expandable))
            }

            if let postCode = contact.postalCode {
                rows.append(.row(title: "Postal Code", content: postCode, style: .expandable))
            }

            if let state = contact.state {
                rows.append(.row(title: "State", content: state, style: .expandable))
            }

            if let country = contact.country {
                if let countryCode = contact.countryCode {
                    rows.append(.row(title: "Country", content: country + "(\(countryCode))", style: .expandable))
                } else {
                    rows.append(.row(title: "Country", content: country, style: .expandable))
                }
            }

            if let email = contact.email {
                rows.append(.row(title: "Email", content: email, style: .expandable))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                rows.append(.row(title: "Fax", content: phone, style: .expandable))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                rows.append(.row(title: "Fax", content: fax, style: .expandable))
            }

            content.append(.multiple(title: "Registrant", contents: rows))
        } else if let contact = record.registryData.regustrant {
            var rows = [CopyCellType]()

            if let name = contact.name {
                rows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let org = contact.organization {
                rows.append(.row(title: "Organization", content: org, style: .expandable))
            }

            var street = [String]()
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
            if !street.isEmpty {
                rows.append(.row(title: "Street", content: street.joined(separator: "\n"), style: .expandable))
            }

            if let city = contact.city {
                rows.append(.row(title: "City", content: city, style: .expandable))
            }

            if let postCode = contact.postalCode {
                rows.append(.row(title: "Postal Code", content: postCode, style: .expandable))
            }

            if let state = contact.state {
                rows.append(.row(title: "State", content: state, style: .expandable))
            }

            content.append(.multiple(title: "Registrant", contents: rows))
        }

        if let contact = record.administrativeContact {
            var rows = [CopyCellType]()
            if let name = contact.name {
                rows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let org = contact.organization {
                rows.append(.row(title: "Organization", content: org, style: .expandable))
            }

            var street = [String]()
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
            if !street.isEmpty {
                rows.append(.row(title: "Street", content: street.joined(separator: "\n"), style: .expandable))
            }

            if let city = contact.city {
                rows.append(.row(title: "City", content: city, style: .expandable))
            }

            if let postCode = contact.postalCode {
                rows.append(.row(title: "Postal Code", content: postCode, style: .expandable))
            }

            if let state = contact.state {
                rows.append(.row(title: "State", content: state, style: .expandable))
            }

            if let country = contact.country {
                if let countryCode = contact.countryCode {
                    rows.append(.row(title: "Country", content: "\(country) (\(countryCode))", style: .expandable))
                } else {
                    rows.append(.row(title: "Country", content: country, style: .expandable))
                }
            }

            if let email = contact.email {
                rows.append(.row(title: "Email", content: email, style: .expandable))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                rows.append(.row(title: "Fax", content: phone, style: .expandable))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                rows.append(.row(title: "Fax", content: fax, style: .expandable))
            }

            content.append(.multiple(title: "Administrative Contact", contents: rows))
        } else if let contact = record.registryData.administrativeContact {
            var rows = [CopyCellType]()
            if let name = contact.name {
                rows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let org = contact.organization {
                rows.append(.row(title: "Organization", content: org, style: .expandable))
            }

            var street = [String]()
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
            if !street.isEmpty {
                rows.append(.row(title: "Street", content: street.joined(separator: "\n"), style: .expandable))
            }

            if let city = contact.city {
                rows.append(.row(title: "City", content: city, style: .expandable))
            }

            if let postCode = contact.postalCode {
                rows.append(.row(title: "Postal Code", content: postCode, style: .expandable))
            }

            if let state = contact.state {
                rows.append(.row(title: "State", content: state, style: .expandable))
            }

            if let country = contact.country {
                if let countryCode = contact.countryCode {
                    rows.append(.row(title: "Country", content: country + "(\(countryCode))", style: .expandable))
                } else {
                    rows.append(.row(title: "Country", content: country, style: .expandable))
                }
            }

            if let email = contact.email {
                rows.append(.row(title: "Email", content: email, style: .expandable))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                rows.append(.row(title: "Fax", content: phone, style: .expandable))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                rows.append(.row(title: "Fax", content: fax, style: .expandable))
            }

            content.append(.multiple(title: "Administrative Contact", contents: rows))
        }
        //
        if let contact = record.technicalContact {
            var rows = [CopyCellType]()
            if let name = contact.name {
                rows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let org = contact.organization {
                rows.append(.row(title: "Organization", content: org, style: .expandable))
            }

            var street = [String]()
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
            if !street.isEmpty {
                rows.append(.row(title: "Street", content: street.joined(separator: "\n"), style: .expandable))
            }

            if let city = contact.city {
                rows.append(.row(title: "City", content: city, style: .expandable))
            }

            if let postCode = contact.postalCode {
                rows.append(.row(title: "Postal Code", content: postCode, style: .expandable))
            }

            if let state = contact.state {
                rows.append(.row(title: "State", content: state, style: .expandable))
            }

            if let country = contact.country {
                if let countryCode = contact.countryCode {
                    rows.append(.row(title: "Country", content: country + "(\(countryCode))", style: .expandable))
                } else {
                    rows.append(.row(title: "Country", content: country, style: .expandable))
                }
            }

            if let email = contact.email {
                rows.append(.row(title: "Email", content: email, style: .expandable))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                rows.append(.row(title: "Fax", content: phone, style: .expandable))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                rows.append(.row(title: "Fax", content: fax, style: .expandable))
            }

            content.append(.multiple(title: "Technical Contact", contents: rows))
        } else if let contact = record.registryData.technicalContact {
            var rows = [CopyCellType]()
            if let name = contact.name {
                rows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let org = contact.organization {
                rows.append(.row(title: "Organization", content: org, style: .expandable))
            }

            var street = [String]()
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
            if !street.isEmpty {
                rows.append(.row(title: "Street", content: street.joined(separator: "\n"), style: .expandable))
            }

            if let city = contact.city {
                rows.append(.row(title: "City", content: city, style: .expandable))
            }

            if let postCode = contact.postalCode {
                rows.append(.row(title: "Postal Code", content: postCode, style: .expandable))
            }

            if let state = contact.state {
                rows.append(.row(title: "State", content: state, style: .expandable))
            }

            if let country = contact.country {
                if let countryCode = contact.countryCode {
                    rows.append(.row(title: "Country", content: country + "(\(countryCode))", style: .expandable))
                } else {
                    rows.append(.row(title: "Country", content: country, style: .expandable))
                }
            }

            if let email = contact.email {
                rows.append(.row(title: "Email", content: email, style: .expandable))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                rows.append(.row(title: "Fax", content: phone, style: .expandable))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                rows.append(.row(title: "Fax", content: fax, style: .expandable))
            }

            content.append(.multiple(title: "Technical Contact", contents: rows))
        }
        //
        if let contact = record.billingContact {
            var rows = [CopyCellType]()
            if let name = contact.name {
                rows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let org = contact.organization {
                rows.append(.row(title: "Organization", content: org, style: .expandable))
            }

            var street = [String]()
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
            if !street.isEmpty {
                rows.append(.row(title: "Street", content: street.joined(separator: "\n"), style: .expandable))
            }

            if let city = contact.city {
                rows.append(.row(title: "City", content: city, style: .expandable))
            }

            if let postCode = contact.postalCode {
                rows.append(.row(title: "Postal Code", content: postCode, style: .expandable))
            }

            if let state = contact.state {
                rows.append(.row(title: "State", content: state, style: .expandable))
            }

            if let country = contact.country {
                if let countryCode = contact.countryCode {
                    rows.append(.row(title: "Country", content: country + "(\(countryCode))", style: .expandable))
                } else {
                    rows.append(.row(title: "Country", content: country, style: .expandable))
                }
            }

            if let email = contact.email {
                rows.append(.row(title: "Email", content: email, style: .expandable))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                rows.append(.row(title: "Fax", content: phone, style: .expandable))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                rows.append(.row(title: "Fax", content: fax, style: .expandable))
            }

            content.append(.multiple(title: "Billing Contact", contents: rows))
        } else if let contact = record.registryData.billingContact {
            var rows = [CopyCellType]()
            if let name = contact.name {
                rows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let org = contact.organization {
                rows.append(.row(title: "Organization", content: org, style: .expandable))
            }

            var street = [String]()
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
            if !street.isEmpty {
                let streetCell = CopyCellType.row(title: "Street", content: street.joined(separator: "\n"), style: .expandable)
                rows.append(streetCell)
            }

            if let city = contact.city {
                rows.append(.row(title: "City", content: city, style: .expandable))
            }

            if let postCode = contact.postalCode {
                rows.append(.row(title: "Postal Code", content: postCode, style: .expandable))
            }

            if let state = contact.state {
                rows.append(.row(title: "State", content: state, style: .expandable))
            }

            if let country = contact.country {
                if let countryCode = contact.countryCode {
                    rows.append(.row(title: "Country", content: country + "(\(countryCode))", style: .expandable))
                } else {
                    rows.append(.row(title: "Country", content: country, style: .expandable))
                }
            }

            if let email = contact.email {
                rows.append(.row(title: "Email", content: email, style: .expandable))
            }

            if var phone = contact.telephone {
                if let phoneExt = contact.telephoneEXT {
                    phone += " \(phoneExt)"
                }

                rows.append(.row(title: "Phone", content: phone, style: .expandable))
            }

            if var fax = contact.fax {
                if let faxExt = contact.faxEXT {
                    fax += " \(faxExt)"
                }

                rows.append(.row(title: "Fax", content: fax, style: .expandable))
            }

            content.append(.multiple(title: "Billing Contact", contents: rows))
        }

        if let domainAvailability = record.domainAvailability {
            content.append(.row(title: "Availability", content: domainAvailability))
        }

        let status = record.status ?? record.registryData.status ?? "Unknown"
        content.append(.row(title: "Status", content: status))

        if let customFieldName = record.customField1Name, let customFieldValue = record.customField1Value {
            let customCell = CopyCellType.row(title: customFieldName, content: customFieldValue)
            content.append(customCell)
        }

        if let customFieldName = record.customField2Name, let customFieldValue = record.customField2Value {
            let customCell = CopyCellType.row(title: customFieldName, content: customFieldValue)
            content.append(customCell)
        }

        if let customFieldName = record.customField3Name, let customFieldValue = record.customField3Value {
            let customCell = CopyCellType.row(title: customFieldName, content: customFieldValue)
            content.append(customCell)
        }
        return copyData
    }

    private let cache = MemoryStorage<String, WhoisRecord>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let host = url?.host else {
            throw URLError(URLError.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        if let record = try? cache.object(forKey: host) {
            return try configure(with: record)
        }

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
            throw MoreStoreKitError.NotPurchased
        }

        let response: Coordinate = try await WhoisXml.whoisService.query(["domain": host])

        cache.setObject(response.whoisRecord, forKey: host)

        return try configure(with: response.whoisRecord)
    }
}
