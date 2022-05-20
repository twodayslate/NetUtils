// swiftlint:disable all

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let coordinate = try Coordinate(json)

//
// To read values from URLs:
//
//   let task = URLSession.shared.coordinateTask(with: url) { coordinate, response, error in
//     if let coordinate = coordinate {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - Coordinate

struct Coordinate: Codable {
    let whoisRecord: WhoisRecord
    let error: String?

    enum CodingKeys: String, CodingKey {
        case whoisRecord = "WhoisRecord"
        case error
    }
}

// MARK: Coordinate convenience initializers and mutators

extension Coordinate {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Coordinate.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        whoisRecord: WhoisRecord? = nil
    ) -> Coordinate {
        return Coordinate(
            whoisRecord: whoisRecord ?? self.whoisRecord,
            error: error
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.whoisRecordTask(with: url) { whoisRecord, response, error in
//     if let whoisRecord = whoisRecord {
//       ...
//     }
//   }
//   task.resume()

// MARK: - WhoisRecord

struct WhoisRecord: Codable {
    let administrativeContact: WhoisRecordAdministrativeContact?
    let audit: WhoisRecordAudit
    let billingContact: WhoisRecordBillingContact?
    let contactEmail: String?
    let createdDate, createdDateNormalized: Date?
    let customField1Name, customField1Value, customField2Name, customField2Value: String?
    let customField3Name, customField3Value: String?
    let domainAvailability, domainName, domainNameEXT: String?
    let estimatedDomainAge: Int?
    let expiresDate, expiresDateNormalized: Date?
    let footer, header: String?
    let ips: [String]?
    let nameServers: WhoisRecordNameServers?
    let parseCode: Int?
    let rawText: String?
    let dataError: String?
    let registrant: Registrant?
    let registrarIANAID, registrarName: String?
    let registryData: RegistryData
    let status, strippedText: String?
    let technicalContact: WhoisRecordTechnicalContact?
    let updatedDate, updatedDateNormalized: Date?
    let whoisServer: String?
    let zoneContact: WhoisRecordZoneContact?

    enum CodingKeys: String, CodingKey {
        case administrativeContact, audit, billingContact, contactEmail, createdDate, createdDateNormalized, customField1Name, customField1Value, customField2Name, dataError, customField2Value, customField3Name, customField3Value, domainAvailability, domainName
        case domainNameEXT = "domainNameExt"
        case estimatedDomainAge, expiresDate, expiresDateNormalized, footer, header, ips, nameServers, parseCode, rawText, registrant, registrarIANAID, registrarName, registryData, status, strippedText, technicalContact, updatedDate, updatedDateNormalized, whoisServer, zoneContact
    }
}

// MARK: WhoisRecord convenience initializers and mutators

extension WhoisRecord {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoisRecord.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

//    func with(
//        administrativeContact: WhoisRecordAdministrativeContact?? = nil,
//        audit: WhoisRecordAudit? = nil,
//        billingContact: WhoisRecordBillingContact?? = nil,
//        contactEmail: String? = nil,
//        createdDate: Date?? = nil,
//        createdDateNormalized: Date?? = nil,
//        customField1Name: String?? = nil,
//        customField1Value: String?? = nil,
//        customField2Name: String?? = nil,
//        customField2Value: String?? = nil,
//        customField3Name: String?? = nil,
//        customField3Value: String?? = nil,
//        domainAvailability: String? = nil,
//        domainName: String? = nil,
//        domainNameEXT: String? = nil,
//        estimatedDomainAge: Int? = nil,
//        expiresDate: Date?? = nil,
//        expiresDateNormalized: Date?? = nil,
//        footer: String?? = nil,
//        header: String?? = nil,
//        ips: [String]?? = nil,
//        nameServers: WhoisRecordNameServers?? = nil,
//        parseCode: Int? = nil,
//        rawText: String?? = nil,
//        registrant: Registrant?? = nil,
//        registrarIANAID: String? = nil,
//        registrarName: String? = nil,
//        registryData: RegistryData? = nil,
//        status: String?? = nil,
//        strippedText: String?? = nil,
//        technicalContact: WhoisRecordTechnicalContact?? = nil,
//        updatedDate: Date?? = nil,
//        updatedDateNormalized: Date?? = nil,
//        whoisServer: String?? = nil,
//        zoneContact: WhoisRecordZoneContact?? = nil
//    ) -> WhoisRecord {
//        return WhoisRecord(
//            administrativeContact: administrativeContact ?? self.administrativeContact,
//            audit: audit ?? self.audit,
//            billingContact: billingContact ?? self.billingContact,
//            contactEmail: contactEmail ?? self.contactEmail,
//            createdDate: createdDate ?? self.createdDate,
//            createdDateNormalized: createdDateNormalized ?? self.createdDateNormalized,
//            customField1Name: customField1Name ?? self.customField1Name,
//            customField1Value: customField1Value ?? self.customField1Value,
//            customField2Name: customField2Name ?? self.customField2Name,
//            customField2Value: customField2Value ?? self.customField2Value,
//            customField3Name: customField3Name ?? self.customField3Name,
//            customField3Value: customField3Value ?? self.customField3Value,
//            domainAvailability: domainAvailability ?? self.domainAvailability,
//            domainName: domainName ?? self.domainName,
//            domainNameEXT: domainNameEXT ?? self.domainNameEXT,
//            estimatedDomainAge: estimatedDomainAge ?? self.estimatedDomainAge,
//            expiresDate: expiresDate ?? self.expiresDate,
//            expiresDateNormalized: expiresDateNormalized ?? self.expiresDateNormalized,
//            footer: footer ?? self.footer,
//            header: header ?? self.header,
//            ips: ips ?? self.ips,
//            nameServers: nameServers ?? self.nameServers,
//            parseCode: parseCode ?? self.parseCode,
//            rawText: rawText ?? self.rawText,
//            registrant: registrant ?? self.registrant,
//            registrarIANAID: registrarIANAID ?? self.registrarIANAID,
//            registrarName: registrarName ?? self.registrarName,
//            registryData: registryData ?? self.registryData,
//            status: status ?? self.status,
//            strippedText: strippedText ?? self.strippedText,
//            technicalContact: technicalContact ?? self.technicalContact,
//            updatedDate: updatedDate ?? self.updatedDate,
//            updatedDateNormalized: updatedDateNormalized ?? self.updatedDateNormalized,
//            whoisServer: whoisServer ?? self.whoisServer,
//            zoneContact: zoneContact ?? self.zoneContact, dataError: nil
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.whoisRecordAdministrativeContactTask(with: url) { whoisRecordAdministrativeContact, response, error in
//     if let whoisRecordAdministrativeContact = whoisRecordAdministrativeContact {
//       ...
//     }
//   }
//   task.resume()

// MARK: - WhoisRecordAdministrativeContact

struct WhoisRecordAdministrativeContact: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: WhoisRecordAdministrativeContact convenience initializers and mutators

extension WhoisRecordAdministrativeContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoisRecordAdministrativeContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> WhoisRecordAdministrativeContact {
        return WhoisRecordAdministrativeContact(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.whoisRecordAuditTask(with: url) { whoisRecordAudit, response, error in
//     if let whoisRecordAudit = whoisRecordAudit {
//       ...
//     }
//   }
//   task.resume()

// MARK: - WhoisRecordAudit

struct WhoisRecordAudit: Codable {
    let createdDate, updatedDate: Date
}

// MARK: WhoisRecordAudit convenience initializers and mutators

extension WhoisRecordAudit {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoisRecordAudit.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        createdDate: Date? = nil,
        updatedDate: Date? = nil
    ) -> WhoisRecordAudit {
        return WhoisRecordAudit(
            createdDate: createdDate ?? self.createdDate,
            updatedDate: updatedDate ?? self.updatedDate
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.whoisRecordBillingContactTask(with: url) { whoisRecordBillingContact, response, error in
//     if let whoisRecordBillingContact = whoisRecordBillingContact {
//       ...
//     }
//   }
//   task.resume()

// MARK: - WhoisRecordBillingContact

struct WhoisRecordBillingContact: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: WhoisRecordBillingContact convenience initializers and mutators

extension WhoisRecordBillingContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoisRecordBillingContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> WhoisRecordBillingContact {
        return WhoisRecordBillingContact(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.whoisRecordNameServersTask(with: url) { whoisRecordNameServers, response, error in
//     if let whoisRecordNameServers = whoisRecordNameServers {
//       ...
//     }
//   }
//   task.resume()

// MARK: - WhoisRecordNameServers

struct WhoisRecordNameServers: Codable {
    let hostNames: [String]
    let ips: [JSONAny]?
    let rawText: String
}

// MARK: WhoisRecordNameServers convenience initializers and mutators

extension WhoisRecordNameServers {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoisRecordNameServers.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        hostNames: [String]? = nil,
        ips: [JSONAny]?? = nil,
        rawText: String? = nil
    ) -> WhoisRecordNameServers {
        return WhoisRecordNameServers(
            hostNames: hostNames ?? self.hostNames,
            ips: ips ?? self.ips,
            rawText: rawText ?? self.rawText
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.registrantTask(with: url) { registrant, response, error in
//     if let registrant = registrant {
//       ...
//     }
//   }
//   task.resume()

// MARK: - Registrant

struct Registrant: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: Registrant convenience initializers and mutators

extension Registrant {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Registrant.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> Registrant {
        return Registrant(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.registryDataTask(with: url) { registryData, response, error in
//     if let registryData = registryData {
//       ...
//     }
//   }
//   task.resume()

// MARK: - RegistryData

struct RegistryData: Codable {
    let administrativeContact: RegistryDataAdministrativeContact?
    let audit: RegistryDataAudit
    let billingContact: RegistryDataBillingContact?
    let createdDate, createdDateNormalized: Date?
    let customField1Name, customField1Value, customField2Name, customField2Value: String?
    let customField3Name, customField3Value: String?
    let domainName: String
    let expiresDate, expiresDateNormalized: Date?
    let footer, header: String?
    let nameServers: RegistryDataNameServers?
    let parseCode: Int
    let rawText: String
    let registrarIANAID, registrarName: String?
    let regustrant: Regustrant?
    let status, strippedText: String?
    let technicalContact: RegistryDataTechnicalContact?
    let updatedDate, updatedDateNormalized: Date?
    let whoisServer: String
    let dataError: String?
    let zoneContact: RegistryDataZoneContact?
}

// MARK: RegistryData convenience initializers and mutators

extension RegistryData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RegistryData.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

//    func with(
//        administrativeContact: RegistryDataAdministrativeContact?? = nil,
//        audit: RegistryDataAudit? = nil,
//        billingContact: RegistryDataBillingContact?? = nil,
//        createdDate: Date? = nil,
//        createdDateNormalized: Date? = nil,
//        customField1Name: String?? = nil,
//        customField1Value: String?? = nil,
//        customField2Name: String?? = nil,
//        customField2Value: String?? = nil,
//        customField3Name: String?? = nil,
//        customField3Value: String?? = nil,
//        domainName: String? = nil,
//        expiresDate: Date? = nil,
//        expiresDateNormalized: Date? = nil,
//        footer: String?? = nil,
//        header: String?? = nil,
//        nameServers: RegistryDataNameServers? = nil,
//        parseCode: Int? = nil,
//        rawText: String? = nil,
//        registrarIANAID: String? = nil,
//        registrarName: String? = nil,
//        regustrant: Regustrant?? = nil,
//        status: String? = nil,
//        strippedText: String? = nil,
//        technicalContact: RegistryDataTechnicalContact?? = nil,
//        updatedDate: Date? = nil,
//        updatedDateNormalized: Date? = nil,
//        whoisServer: String? = nil,
//        zoneContact: RegistryDataZoneContact?? = nil
//    ) -> RegistryData {
//        return RegistryData(
//            administrativeContact: administrativeContact ?? self.administrativeContact,
//            audit: audit ?? self.audit,
//            billingContact: billingContact ?? self.billingContact,
//            createdDate: createdDate ?? self.createdDate,
//            createdDateNormalized: createdDateNormalized ?? self.createdDateNormalized,
//            customField1Name: customField1Name ?? self.customField1Name,
//            customField1Value: customField1Value ?? self.customField1Value,
//            customField2Name: customField2Name ?? self.customField2Name,
//            customField2Value: customField2Value ?? self.customField2Value,
//            customField3Name: customField3Name ?? self.customField3Name,
//            customField3Value: customField3Value ?? self.customField3Value,
//            domainName: domainName ?? self.domainName,
//            expiresDate: expiresDate ?? self.expiresDate,
//            expiresDateNormalized: expiresDateNormalized ?? self.expiresDateNormalized,
//            footer: footer ?? self.footer,
//            header: header ?? self.header,
//            nameServers: nameServers ?? self.nameServers,
//            parseCode: parseCode ?? self.parseCode,
//            rawText: rawText ?? self.rawText,
//            registrarIANAID: registrarIANAID ?? self.registrarIANAID,
//            registrarName: registrarName ?? self.registrarName,
//            regustrant: regustrant ?? self.regustrant,
//            status: status ?? self.status,
//            strippedText: strippedText ?? self.strippedText,
//            technicalContact: technicalContact ?? self.technicalContact,
//            updatedDate: updatedDate ?? self.updatedDate,
//            updatedDateNormalized: updatedDateNormalized ?? self.updatedDateNormalized,
//            whoisServer: whoisServer ?? self.whoisServer,
//            zoneContact: zoneContact ?? self.zoneContact,
//            dataError: nil
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.registryDataAdministrativeContactTask(with: url) { registryDataAdministrativeContact, response, error in
//     if let registryDataAdministrativeContact = registryDataAdministrativeContact {
//       ...
//     }
//   }
//   task.resume()

// MARK: - RegistryDataAdministrativeContact

struct RegistryDataAdministrativeContact: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: RegistryDataAdministrativeContact convenience initializers and mutators

extension RegistryDataAdministrativeContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RegistryDataAdministrativeContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> RegistryDataAdministrativeContact {
        return RegistryDataAdministrativeContact(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.registryDataAuditTask(with: url) { registryDataAudit, response, error in
//     if let registryDataAudit = registryDataAudit {
//       ...
//     }
//   }
//   task.resume()

// MARK: - RegistryDataAudit

struct RegistryDataAudit: Codable {
    let createdDate, updatedDate: Date
}

// MARK: RegistryDataAudit convenience initializers and mutators

extension RegistryDataAudit {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RegistryDataAudit.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        createdDate: Date? = nil,
        updatedDate: Date? = nil
    ) -> RegistryDataAudit {
        return RegistryDataAudit(
            createdDate: createdDate ?? self.createdDate,
            updatedDate: updatedDate ?? self.updatedDate
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.registryDataBillingContactTask(with: url) { registryDataBillingContact, response, error in
//     if let registryDataBillingContact = registryDataBillingContact {
//       ...
//     }
//   }
//   task.resume()

// MARK: - RegistryDataBillingContact

struct RegistryDataBillingContact: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: RegistryDataBillingContact convenience initializers and mutators

extension RegistryDataBillingContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RegistryDataBillingContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> RegistryDataBillingContact {
        return RegistryDataBillingContact(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.registryDataNameServersTask(with: url) { registryDataNameServers, response, error in
//     if let registryDataNameServers = registryDataNameServers {
//       ...
//     }
//   }
//   task.resume()

// MARK: - RegistryDataNameServers

struct RegistryDataNameServers: Codable {
    let hostNames: [String]
    let ips: [JSONAny]?
    let rawText: String
}

// MARK: RegistryDataNameServers convenience initializers and mutators

extension RegistryDataNameServers {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RegistryDataNameServers.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        hostNames: [String]? = nil,
        ips: [JSONAny]?? = nil,
        rawText: String? = nil
    ) -> RegistryDataNameServers {
        return RegistryDataNameServers(
            hostNames: hostNames ?? self.hostNames,
            ips: ips ?? self.ips,
            rawText: rawText ?? self.rawText
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.regustrantTask(with: url) { regustrant, response, error in
//     if let regustrant = regustrant {
//       ...
//     }
//   }
//   task.resume()

// MARK: - Regustrant

struct Regustrant: Codable {
    let city, name, organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4: String?
    let unparsable: String
}

// MARK: Regustrant convenience initializers and mutators

extension Regustrant {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Regustrant.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        unparsable: String? = nil
    ) -> Regustrant {
        return Regustrant(
            city: city ?? self.city,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.registryDataTechnicalContactTask(with: url) { registryDataTechnicalContact, response, error in
//     if let registryDataTechnicalContact = registryDataTechnicalContact {
//       ...
//     }
//   }
//   task.resume()

// MARK: - RegistryDataTechnicalContact

struct RegistryDataTechnicalContact: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: RegistryDataTechnicalContact convenience initializers and mutators

extension RegistryDataTechnicalContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RegistryDataTechnicalContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> RegistryDataTechnicalContact {
        return RegistryDataTechnicalContact(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.registryDataZoneContactTask(with: url) { registryDataZoneContact, response, error in
//     if let registryDataZoneContact = registryDataZoneContact {
//       ...
//     }
//   }
//   task.resume()

// MARK: - RegistryDataZoneContact

struct RegistryDataZoneContact: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: RegistryDataZoneContact convenience initializers and mutators

extension RegistryDataZoneContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RegistryDataZoneContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> RegistryDataZoneContact {
        return RegistryDataZoneContact(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.whoisRecordTechnicalContactTask(with: url) { whoisRecordTechnicalContact, response, error in
//     if let whoisRecordTechnicalContact = whoisRecordTechnicalContact {
//       ...
//     }
//   }
//   task.resume()

// MARK: - WhoisRecordTechnicalContact

struct WhoisRecordTechnicalContact: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: WhoisRecordTechnicalContact convenience initializers and mutators

extension WhoisRecordTechnicalContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoisRecordTechnicalContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> WhoisRecordTechnicalContact {
        return WhoisRecordTechnicalContact(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.whoisRecordZoneContactTask(with: url) { whoisRecordZoneContact, response, error in
//     if let whoisRecordZoneContact = whoisRecordZoneContact {
//       ...
//     }
//   }
//   task.resume()

// MARK: - WhoisRecordZoneContact

struct WhoisRecordZoneContact: Codable {
    let city: String?
    let country, countryCode: String?
    let email, fax, faxEXT, name: String?
    let organization, postalCode: String?
    let rawText: String
    let state, street1, street2, street3: String?
    let street4, telephone, telephoneEXT, unparsable: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, email, fax
        case faxEXT = "faxExt"
        case name, organization, postalCode, rawText, state, street1, street2, street3, street4, telephone
        case telephoneEXT = "telephoneExt"
        case unparsable
    }
}

// MARK: WhoisRecordZoneContact convenience initializers and mutators

extension WhoisRecordZoneContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoisRecordZoneContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String?? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        email: String?? = nil,
        fax: String?? = nil,
        faxEXT: String?? = nil,
        name: String?? = nil,
        organization: String?? = nil,
        postalCode: String?? = nil,
        rawText: String? = nil,
        state: String?? = nil,
        street1: String?? = nil,
        street2: String?? = nil,
        street3: String?? = nil,
        street4: String?? = nil,
        telephone: String?? = nil,
        telephoneEXT: String?? = nil,
        unparsable: String?? = nil
    ) -> WhoisRecordZoneContact {
        return WhoisRecordZoneContact(
            city: city ?? self.city,
            country: country ?? self.country,
            countryCode: countryCode ?? self.countryCode,
            email: email ?? self.email,
            fax: fax ?? self.fax,
            faxEXT: faxEXT ?? self.faxEXT,
            name: name ?? self.name,
            organization: organization ?? self.organization,
            postalCode: postalCode ?? self.postalCode,
            rawText: rawText ?? self.rawText,
            state: state ?? self.state,
            street1: street1 ?? self.street1,
            street2: street2 ?? self.street2,
            street3: street3 ?? self.street3,
            street4: street4 ?? self.street4,
            telephone: telephone ?? self.telephone,
            telephoneEXT: telephoneEXT ?? self.telephoneEXT,
            unparsable: unparsable ?? self.unparsable
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
    private func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func coordinateTask(with url: URL, completionHandler: @escaping (Coordinate?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return codableTask(with: url, completionHandler: completionHandler)
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    public static func == (_: JSONNull, _: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into _: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue _: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {
    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: value)
        }
    }
}
