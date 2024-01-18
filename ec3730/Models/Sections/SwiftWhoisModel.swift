//
//  FreeSwiftWhoisModel.swift
//  ec3730
//
//  Created by Upwork on 17/01/24.
//  Copyright © 2024 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftWhois
@MainActor
class FreeSwiftWhoisModel: HostSectionModel {
    required convenience init() {
        self.init(FreeSwiftWhois.current, service: FreeSwiftWhois.lookupService)
    }

    override func configure(with data: Data?) throws -> Data? {
        reset()

        guard let data = data else {
            return nil
        }

        let addresses = try JSONDecoder().decode(WhoisDataModel.self, from: data)

        return try configure(addresses: addresses)
    }

    func configure(addresses: WhoisDataModel) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(addresses)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

//        for address in addresses {
        content.append(.row(title: "Domain", content: addresses.domainName ?? ""))
//        }

        return copyData
    }

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let host = url?.host else {
            throw URLError(URLError.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        let addresses: WhoisDataModel = try await service.query(["host": host])

        return try configure(addresses: addresses)
    }
}


public struct WhoisDataModel: Codable {
    public var domainName: String?
    public var registrar: String?
    public var registrarWhoisServer: String?
    public var registrantContactEmail: String?
    public var registrant: String?
    public var creationDate: String?
    public var expirationDate: String?
    public var updateDate: String?
    public var nameServers: [String]?
    public var domainStatus: [String]?
    public var rawData: String?

    // If you have custom coding keys, you can define them like this:
    private enum CodingKeys: String, CodingKey {
        case domainName
        case registrar
        case registrarWhoisServer
        case registrantContactEmail
        case registrant
        case creationDate
        case expirationDate
        case updateDate
        case nameServers
        case domainStatus
        case rawData
    }

    // Initializer to create WhoisDataModel from WhoisData
    init(from whoisData: WhoisData) {
        self.domainName = whoisData.domainName
        self.registrar = whoisData.registrar
        self.registrarWhoisServer = whoisData.registrarWhoisServer
        self.registrantContactEmail = whoisData.registrantContactEmail
        self.registrant = whoisData.registrant
        self.creationDate = whoisData.creationDate
        self.expirationDate = whoisData.expirationDate
        self.updateDate = whoisData.updateDate
        self.nameServers = whoisData.nameServers
        self.domainStatus = whoisData.domainStatus
        self.rawData = whoisData.rawData
    }
}
