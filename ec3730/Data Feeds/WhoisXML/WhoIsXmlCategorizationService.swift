//
//  WhoIsXmlCategorizationService.swift
//  ec3730
//
//  Created by admin on 04/11/22.
//  Copyright © 2022 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class WhoIsXmlCategorizationService: WhoisXMLService {
    override func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint? {
        guard let userData = userData, let userInput = userData["url"] as? URL, let url_string = userInput.host?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }

        var params = [URLQueryItem(name: "url", value: url_string),
                      URLQueryItem(name: "outputFormat", value: "JSON"),
                      URLQueryItem(name: "api", value: "whoisXmlWebsiteCategorization"),
                      URLQueryItem(name: "identifierForVendor", value: UIDevice.current.identifierForVendor?.uuidString),
                      URLQueryItem(name: "bundleIdentifier", value: Bundle.main.bundleIdentifier)]
        if let key = WhoisXml.current.userKey {
            params.append(URLQueryItem(name: "apiKey", value: key))
        }
        return WhoisXml.Endpoint(host: "api.netutils.workers.dev", path: "/api/v3", queryItems: params)
    }
}
