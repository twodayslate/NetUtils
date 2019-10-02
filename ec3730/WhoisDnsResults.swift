//
//  WhoisDnsResults.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/19/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

struct DnsCoordinate: Codable {
    let dnsData: DNSResults

    enum CodingKeys: String, CodingKey {
        case dnsData = "DNSData"
    }
}

extension DnsCoordinate {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DnsCoordinate.self, from: data)
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
        whoisRecord: DNSResults? = nil
    ) -> DnsCoordinate {
        return DnsCoordinate(dnsData: whoisRecord ?? dnsData)
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

struct DNSResults: Codable {
    let domainName: String
    let types: [Int]
    let dnsTypes: String
    let audit: WhoisRecordAudit
    let dnsRecords: [DNSRecords]?
}

extension DNSResults {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DNSResults.self, from: data)
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
        domainName: String? = nil, types: [Int]? = nil,
        dnsTypes: String? = nil, audit: WhoisRecordAudit? = nil, records: [DNSRecords]? = nil
    ) -> DNSResults {
        return DNSResults(domainName: domainName ?? self.domainName, types: types ?? self.types,
                          dnsTypes: dnsTypes ?? self.dnsTypes, audit: audit ?? self.audit, dnsRecords: records ?? dnsRecords)
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

struct DNSRecords: Codable {
    let type: Int
    let dnsType: String
    let name: String
    let ttl: Int
    let rRsetType: Int
    let rawText: String

    // optionals
    let address: String?
    let admin: String?
    let host: String?
    let expire: Int?
    let minimum: Int?
    let refresh: Int?
    let retry: Int?
    let serial: Int?
    let strings: [String]?
}
