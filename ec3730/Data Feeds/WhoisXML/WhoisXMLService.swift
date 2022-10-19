//
//  WhoisXMLService.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class WhoisXMLService: Service {
    // MARK: - Properties

    var name: String
    var id: String
    var description: String

    static var cache = [String: TimedCache]()

    var cache: TimedCache {
        if let currentCache = WhoisXMLService.cache[id] {
            return currentCache
        }
        WhoisXMLService.cache[id] = TimedCache(expiresIn: 600) // 10 minutes
        return WhoisXMLService.cache[id]!
    }

    // MARK: - Initializers

    init(name: String, description: String, id: String) {
        self.name = name
        self.id = id
        self.description = description
    }

    func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint? {
        guard let userData = userData, let userInput = userData["domain"] as? String, let domain = userInput.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }

        var api = "whoisXml"
        switch self {
        case WhoisXml.reputationService:
            api = "whoisXmlReputation"
        default:
            api = "whoisXml"
        }

        var params = [
            URLQueryItem(name: "domainName", value: domain),
            URLQueryItem(name: "outputFormat", value: "JSON"),
            URLQueryItem(name: "da", value: "2"),
            URLQueryItem(name: "ip", value: "1"),
            URLQueryItem(name: "api", value: api),
            URLQueryItem(name: "service_name", value: name),
            URLQueryItem(name: "service_id", value: id),
            URLQueryItem(name: "identifierForVendor", value: UIDevice.current.identifierForVendor?.uuidString),
            URLQueryItem(name: "bundleIdentifier", value: Bundle.main.bundleIdentifier),
        ]

        if let key = WhoisXml.current.userKey {
            params.append(URLQueryItem(name: "apiKey", value: key))
        }

        var path: String!
        switch self {
        case WhoisXml.reputationService:
            path = "/api/v1"
        default:
            path = "/whoisserver/WhoisService"
        }

        return WhoisXml.Endpoint(host: "api.netutils.workers.dev", path: path, queryItems: params)
    }

    func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?) {
        guard let endpoint = endpoint(userData), let endpointURL = endpoint.url else {
            block?(DataFeedError.invalidUrl, nil)
            return
        }

        let minimumBalance = userData?["minimumBalance"] as? Int ?? 100

        usage += 1

        if let cached: T = cache.value(for: endpointURL.absoluteString) {
            block?(nil, cached)
            return
        }

        balance(key: WhoisXml.current.userKey) { error, balance in
            guard error == nil else {
                block?(error, nil)
                return
            }

            guard let balance = balance else {
                block?(DataFeedError.nil, nil) // TODO: set error
                return
            }

            guard balance > minimumBalance else {
                block?(DataFeedError.lowBalance(balance: balance), nil) // TODO: set error
                return
            }

            WhoisXml.session.dataTask(with: endpointURL) { data, _, error in
                guard error == nil else {
                    block?(error, nil)
                    return
                }
                guard let data = data else {
                    block?(DataFeedError.empty, nil)
                    return
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom {
                    decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)

                    let formatter = DateFormatter()
                    let formats = [
                        "yyyy-MM-dd HH:mm:ss",
                        "yyyy-MM-dd",
                        "yyyy-MM-dd HH:mm:ss.SSS ZZZ",
                        "yyyy-MM-dd HH:mm:ss ZZZ", // 1997-09-15 07:00:00 UTC,
                        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", // 2016-11-05T04:45:03.00Z
                    ]

                    for format in formats {
                        formatter.dateFormat = format
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }

                    let iso = ISO8601DateFormatter()
                    iso.timeZone = TimeZone(abbreviation: "UTC")
                    if let date = iso.date(from: dateString) {
                        return date
                    }

                    if let date = ISO8601DateFormatter().date(from: dateString) {
                        return date
                    }

                    throw DecodingError.dataCorruptedError(in: container,
                                                           debugDescription: "Cannot decode date string \(dateString)")
                }

                do {
                    let coordinator = try decoder.decode(T.self, from: data)
                    self.cache.add(coordinator, for: endpointURL.absoluteString)
                    block?(nil, coordinator)
                } catch let decodeError {
                    print(decodeError, T.self, self.name)
                    print(String(data: data, encoding: .utf8) ?? "")
                    block?(decodeError, nil)
                }
            }.resume()
        }
    }

    func balance(key: String?, completion block: ((Error?, Int?) -> Void)? = nil) {
        guard let balanceURL = WhoisXml.Endpoint.balanceUrl(for: id, with: key) else {
            block?(DataFeedError.invalidUrl, nil) // TODO: set error
            return
        }

        WhoisXml.session.dataTask(with: balanceURL) { data, _, error in
            guard error == nil else {
                block?(error, nil)
                return
            }
            guard let data = data else {
                block?(DataFeedError.empty, nil)
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                block?(DataFeedError.parse, nil) // TODO: set error
                return
            }

            guard let jsonDataArray = json["data"] as? [Any?], jsonDataArray.count == 1, let first = jsonDataArray[0] as? [String: Any?], let balance = first["credits"] as? Int else {
                block?(DataFeedError.parse, nil) // TODO: set error
                return
            }

            block?(nil, balance)
        }.resume()
    }

    func query<T>(_ userData: [String: Any?]?) async throws -> T where T: Decodable, T: Encodable {
        guard let endpoint = endpoint(userData), let endpointURL = endpoint.url else {
            throw DataFeedError.invalidUrl
        }
        print("endpoint-----------")
        print(endpoint.url!)
        print(endpoint.host)
        print(endpoint.path)
        print(endpoint.queryItems)
        print(endpoint.schema)
        let minimumBalance = userData?["minimumBalance"] as? Int ?? 100

        if let cached: T = cache.value(for: endpointURL.absoluteString) {
            usage += 1
            return cached
        }

        let balance = try await balance(for: WhoisXml.current.userKey)

        guard balance > minimumBalance else {
            throw DataFeedError.lowBalance(balance: balance)
        }

        usage += 1

        let (data, _) = try await WhoisXml.session.data(from: endpointURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom {
            decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatter = DateFormatter()
            let formats = [
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd",
                "yyyy-MM-dd HH:mm:ss.SSS ZZZ",
                "yyyy-MM-dd HH:mm:ss ZZZ", // 1997-09-15 07:00:00 UTC,
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", // 2016-11-05T04:45:03.00Z
            ]

            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            let iso = ISO8601DateFormatter()
            iso.timeZone = TimeZone(abbreviation: "UTC")
            if let date = iso.date(from: dateString) {
                return date
            }

            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot decode date string \(dateString)")
        }

        let coordinator = try decoder.decode(T.self, from: data)
        cache.add(coordinator, for: endpointURL.absoluteString)
        return coordinator
    }

    func balance(for key: String?) async throws -> Int {
        guard let balanceURL = WhoisXml.Endpoint.balanceUrl(for: id, with: key) else {
            throw DataFeedError.invalidUrl
        }

        let (data, _) = try await WhoisXml.session.data(from: balanceURL)

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw DataFeedError.parse
        }

        guard let jsonDataArray = json["data"] as? [Any?], jsonDataArray.count == 1, let first = jsonDataArray[0] as? [String: Any?], let balance = first["credits"] as? Int else {
            throw DataFeedError.parse
        }

        return balance
    }
}

extension WhoisXMLService: Equatable {
    static func == (lhs: WhoisXMLService, rhs: WhoisXMLService) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}
