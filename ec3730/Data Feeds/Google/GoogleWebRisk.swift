//
//  GoogleWebRisk.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import CloudKit
import CoreData
import Foundation
import KeychainAccess
import StoreKit
import SwiftyStoreKit

final class GoogleWebRisk: DataFeedSingleton, DataFeedOneTimePurchase {
    var name: String = "Google Web Risk API"

    var webpage: URL = .init(string: "https://cloud.google.com/web-risk/")!

    public var userKey: String? {
        didSet {
            let keychian = Keychain().synchronizable(true)
            if let key = userKey {
                try? keychian.set(key, key: UserDefaults.NetUtils.Keys.keyFor(dataFeed: self))
            } else {
                try? keychian.remove(UserDefaults.NetUtils.Keys.keyFor(dataFeed: self))
            }
        }
    }

    public static var current: GoogleWebRisk = {
        let retVal = GoogleWebRisk()
        let keychian = Keychain().synchronizable(true)
        if let key = try? keychian.get(UserDefaults.NetUtils.Keys.keyFor(dataFeed: retVal)) {
            retVal.userKey = key
        }
        return retVal
    }()

    static var session = URLSession.shared

    var oneTime: OneTimePurchase = .init("googlewebrisk.onetime")

    var services: [Service] = {
        [GoogleWebRisk.lookupService]
    }()
}

// MARK: - Endpoints

extension GoogleWebRisk {
    typealias Endpoints = Endpoint

    enum ThreatTypes: String, Codable {
        case unspecified = "THREAT_TYPE_UNSPECIFIED"
        case malware = "MALWARE"
        case socialEngineering = "SOCIAL_ENGINEERING"
        case unwanted = "UNWANTED_SOFTWARE"

        var description: String {
            switch self {
            case .malware:
                return "Malware targeting any platform"
            case .unwanted:
                return "Unwanted software targeting any platform"
            case .socialEngineering:
                return "Social engineering targeting any platform"
            default:
                return "Unknown"
            }
        }
    }

    /// A URL endpoint
    /// - SeeAlso:
    /// [Constructing URLs in Swift](https://www.swiftbysundell.com/posts/constructing-urls-in-swift)
    class Endpoint: DataFeedEndpoint {
        /// https://webrisk.googleapis.com/v1beta1/uris:search?key=YOUR_API_KEY&threatTypes=MALWARE&uri=http%3A%2F%2Ftestsafebrowsing.appspot.com%2Fs%2Fmalware.html
        static func lookup(uri: String, threats: [ThreatTypes] = [.malware, .unwanted, .socialEngineering], with _: String? = nil) -> Endpoint? {
            guard let fixedURI = uri.addingPercentEncoding(withAllowedCharacters: []) else {
                return nil
            }

            var threatItems = [
                URLQueryItem(name: "uri", value: fixedURI),
                URLQueryItem(name: "api", value: "webRisk"),
                URLQueryItem(name: "identifierForVendor", value: UIDevice.current.identifierForVendor?.uuidString),
                URLQueryItem(name: "bundleIdentifier", value: Bundle.main.bundleIdentifier),
            ]

            if let key = GoogleWebRisk.current.userKey {
                threatItems.append(URLQueryItem(name: "key", value: key))
            }

            for threat in threats {
                threatItems.append(URLQueryItem(name: "threatTypes", value: threat.rawValue))
            }

            return Endpoint(host: "api.netutils.workers.dev",
                            path: "/v1beta1/uris:search", queryItems: threatItems)
        }
    }
}

// MARK: - DataFeedService

extension GoogleWebRisk: DataFeedService {
    var totalUsage: Int {
        services.reduce(0) { $0 + $1.usage }
    }

    public static var lookupService: GoogleWebRiskLookupService = .init()

    class GoogleWebRiskLookupService: Service {
        var name: String = "Google Web Risk Lookup API"
        var description: String = "Detect malicious URLs and unsafe web resources"

        var cache = TimedCache(expiresIn: 60)

        func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint? {
            guard let uri = userData?["uri"] as? String else {
                return nil
            }
            return GoogleWebRisk.Endpoint.lookup(uri: uri)
        }

        func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?) {
            guard let endpoint = endpoint(userData), let endpointURL = endpoint.url else {
                block?(DataFeedError.invalidUrl, nil)
                return
            }

            usage += 1

            if let cached: T = cache.value(for: endpointURL.absoluteString) {
                block?(nil, cached)
                return
            }

            GoogleWebRisk.session.dataTask(with: endpointURL) { data, _, error in
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
                        "yyyy-MM-dd HH:mm:ss ZZZ", // 1997-09-15 07:00:00 UTC
                        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // 2019-10-17T06:38:04.993563079Z
                    ]

                    // 2019-10-17T06:38:04.993563079Z

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

                    let isoProto = ISO8601DateFormatter()
                    isoProto.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    isoProto.timeZone = TimeZone(secondsFromGMT: 0)!
                    if let date = isoProto.date(from: dateString) {
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

        func query<T>(_ userData: [String: Any?]?) async throws -> T where T: Decodable, T: Encodable {
            guard let endpoint = endpoint(userData), let endpointURL = endpoint.url else {
                throw DataFeedError.invalidUrl
            }

            usage += 1

            if let cached: T = cache.value(for: endpointURL.absoluteString) {
                return cached
            }

            let (data, _) = try await GoogleWebRisk.session.data(from: endpointURL)

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
                    "yyyy-MM-dd HH:mm:ss ZZZ", // 1997-09-15 07:00:00 UTC
                    "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // 2019-10-17T06:38:04.993563079Z
                ]

                // 2019-10-17T06:38:04.993563079Z

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

                let isoProto = ISO8601DateFormatter()
                isoProto.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                isoProto.timeZone = TimeZone(secondsFromGMT: 0)!
                if let date = isoProto.date(from: dateString) {
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
    }
}
