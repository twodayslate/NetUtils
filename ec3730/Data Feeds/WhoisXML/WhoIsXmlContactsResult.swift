//
//  WhoIsXmlContactsResult.swift
//  ec3730
//
//  Created by Jaspreet Singh on 18/10/22.
//  Copyright © 2022 Zachary Gorak. All rights reserved.
//

import Foundation

// MARK: - WhoIsXmlContactsResult

struct WhoIsXmlContactsResult: Codable {
    let companyNames: [String]?
    let countryCode, domainName: String?
    let emails: [EmailData]?
    let meta: Meta?
    let phones: [PhoneData]?
    let postalAddresses: [String]?
    let socialLinks: SocialLinks?
    let websiteResponded: Bool?
}

extension WhoIsXmlContactsResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoIsXmlContactsResult.self, from: data)
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

    func with(companyNames: [String]? = nil, countryCode: String? = nil, domainName: String? = nil, emails: [EmailData]? = nil, meta: Meta? = nil, phones: [PhoneData]? = nil, postalAddresses: [String]? = nil, socialLinks: SocialLinks? = nil, websiteResponded: Bool? = nil) -> WhoIsXmlContactsResult {
        WhoIsXmlContactsResult(companyNames: companyNames ?? self.companyNames, countryCode: countryCode ?? self.countryCode, domainName: domainName ?? self.domainName, emails: emails ?? self.emails, meta: meta ?? self.meta, phones: phones ?? self.phones, postalAddresses: postalAddresses ?? self.postalAddresses, socialLinks: socialLinks ?? self.socialLinks, websiteResponded: websiteResponded ?? self.websiteResponded)
    }

    func jsonData() throws -> Data {
        try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        String(data: try jsonData(), encoding: encoding)
    }
}

// MARK: - Email

struct EmailData: Codable {
    let emailDescription, email: String?

    enum CodingKeys: String, CodingKey {
        case emailDescription = "description"
        case email
    }
}

// MARK: - Meta

struct Meta: Codable {
    let metaDescription, title: String?

    enum CodingKeys: String, CodingKey {
        case metaDescription = "description"
        case title
    }
}

// MARK: - Phone

struct PhoneData: Codable {
    let callHours, phoneDescription, phoneNumber: String?

    enum CodingKeys: String, CodingKey {
        case callHours
        case phoneDescription = "description"
        case phoneNumber
    }
}

// MARK: - SocialLinks

struct SocialLinks: Codable {
    let facebook, instagram, linkedIn, twitter: String?
}
