//
//  FreeSwiftWhoisDataModel.swift
//  ec3730
//
//  Created by Upwork on 19/01/24.
//  Copyright © 2024 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import SwiftWhois


 struct FreeSwiftWhoisDataModel: Codable {
     var domainName: String?
     var registrar: String?
     var registrarWhoisServer: String?
     var registrantContactEmail: String?
     var registrant: String?
     var creationDate: String?
     var expirationDate: String?
     var updateDate: String?
     var nameServers: [String]?
     var domainStatus: [String]?
     var rawData: String?

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
