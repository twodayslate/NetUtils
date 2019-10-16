//
//  DataFeedEndpoint.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/10/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

open class DataFeedEndpoint {
    var schema: String
    var host: String
    var path: String
    var queryItems: [URLQueryItem]

    init(schema: String = "https", host: String, path: String = "", queryItems: [URLQueryItem] = []) {
        self.schema = schema
        self.host = host
        self.path = path
        self.queryItems = queryItems
    }

    func with(schema: String? = nil, host: String? = nil, path: String? = nil, queryItems: [URLQueryItem]? = nil) -> DataFeedEndpoint {
        return DataFeedEndpoint(schema: schema ?? self.schema,
                                host: host ?? self.host,
                                path: path ?? self.path,
                                queryItems: queryItems ?? self.queryItems)
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = schema
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}
