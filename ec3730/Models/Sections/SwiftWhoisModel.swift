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

        let swiftWhoisdataModel = try JSONDecoder().decode(FreeSwiftWhoisDataModel.self, from: data)

        return try configure(dataModel: swiftWhoisdataModel)
    }

    func configure(dataModel: FreeSwiftWhoisDataModel) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(dataModel)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)
        content.append(.row(title: "Domain", content: dataModel.domainName ?? ""))
        content.append(.row(title: "Registrar", content: dataModel.registrar ?? ""))
        content.append(.row(title: "RegistrarWhoisServer", content: dataModel.registrarWhoisServer ?? ""))
        content.append(.row(title: "CreationDate", content: dataModel.creationDate ?? ""))
        content.append(.row(title: "ExpirationDate", content: dataModel.expirationDate ?? ""))
        content.append(.row(title: "UpdateDate", content: dataModel.updateDate ?? ""))
        content.append(.row(title: "NameServers", content: dataModel.nameServers?.joined(separator: "\n") ?? ""))
        content.append(.row(title: "DomainStatus", content: dataModel.domainStatus?.joined(separator: "\n") ?? ""))

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

        let whoisDataModel: FreeSwiftWhoisDataModel = try await service.query(["host": host])

        return try configure(dataModel: whoisDataModel)
    }
}


