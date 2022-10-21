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

        let params = [URLQueryItem(name: "domainName", value: domain),
                      URLQueryItem(name: "apiKey", value: "at_l54dNyKOiaxH5KV9BWZbNPiOkksmK")]

        return WhoisXml.Endpoint(host: "website-contacts.whoisxmlapi.com", path: "/api/v1", queryItems: params)
    }
}
