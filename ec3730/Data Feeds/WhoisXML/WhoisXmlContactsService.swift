//
//  WhoisXmlContactsService.swift
//  ec3730
//
//  Created by Jaspreet Singh on 18/10/22.
//  Copyright © 2022 Zachary Gorak. All rights reserved.
//

import Foundation

import UIKit

class WhoisXmlContactsService: WhoisXMLService {
    override func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint? {
        guard let userData = userData, let userInput = userData["domain"] as? String, let domain = userInput.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }

        var params = [URLQueryItem(name: "domainName", value: domain),
                      URLQueryItem(name: "outputFormat", value: "JSON"),
                      URLQueryItem(name: "type", value: "_all"),
                      URLQueryItem(name: "api", value: "whoisXml"),
                      URLQueryItem(name: "identifierForVendor", value: UIDevice.current.identifierForVendor?.uuidString),
                      URLQueryItem(name: "bundleIdentifier", value: Bundle.main.bundleIdentifier)]

        if let key = WhoisXml.current.userKey {
            params.append(URLQueryItem(name: "apiKey", value: key))
        }

        return WhoisXml.Endpoint(host: "api.netutils.workers.dev", path: "/whoisserver/DNSService", queryItems: params)
    }
}
