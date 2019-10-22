//
//  WhoisXMLDnsService.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

class WhoisXMLDnsService: WhoisXMLService {
    override func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint? {
        guard let userData = userData, let userInput = userData["domain"] as? String, let domain = userInput.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }

        return WhoisXml.Endpoint(host: "www.whoisxmlapi.com", path: "/whoisserver/DNSService", queryItems: [
            URLQueryItem(name: "domainName", value: domain),
            URLQueryItem(name: "apiKey", value: WhoisXml.current.currentKey.key),
            URLQueryItem(name: "outputFormat", value: "JSON"),
            URLQueryItem(name: "type", value: "_all")
        ])
    }
}
