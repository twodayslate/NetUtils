//
//  GoogleWebRisk.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

final class GoogleWebRisk: DataFeedSingleton, DataFeedOneTimePurchase {
    var name: String = "Google Web Risk API"

    var key: ApiKey = ApiKey.GoogleWebRisk

    var webpage: URL = URL(string: "https://cloud.google.com/web-risk/")!

    public var userKey: ApiKey? {
        didSet {
            if let key = self.userKey {
                UserDefaults.standard.set(key.key, forKey: UserDefaults.NetUtils.Keys.keyFor(dataFeed: self))
                UserDefaults.standard.synchronize()
            }
        }
    }

    public static var current: GoogleWebRisk = {
        let retVal = GoogleWebRisk()
        if let key = UserDefaults.standard.string(forKey: UserDefaults.NetUtils.Keys.keyFor(dataFeed: retVal)) {
            retVal.userKey = ApiKey(name: retVal.name, key: key)
        }
        return retVal
    }()

    static var session = URLSession.shared

    var oneTime: OneTimePurchase = OneTimePurchase("googlewebrisk.onetime")

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
        static func lookup(uri: String, threats: [ThreatTypes] = [.malware, .unwanted, .socialEngineering], with key: String = ApiKey.GoogleWebRisk.key) -> Endpoint? {
            guard let fixedURI = uri.addingPercentEncoding(withAllowedCharacters: []) else {
                return nil
            }

            var threatItems = [URLQueryItem(name: "key", value: key), URLQueryItem(name: "uri", value: fixedURI)]

            for threat in threats {
                threatItems.append(URLQueryItem(name: "threatTypes", value: threat.rawValue))
            }

            return Endpoint(host: "webrisk.googleapis.com",
                            path: "/v1beta1/uris:search", queryItems: threatItems)
        }
    }
}

// MARK: - DataFeedService

extension GoogleWebRisk: DataFeedService {
    public static var lookupService: GoogleWebRiskLookupService = {
        GoogleWebRiskLookupService()
    }()

    class GoogleWebRiskLookupService: Service {
        var name: String = "Google Web Risk Lookup API"

        var cache = TimedCache(expiresIn: 60)

        func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint? {
            guard let uri = userData?["uri"] as? String else {
                return nil
            }
            return GoogleWebRisk.Endpoint.lookup(uri: uri)
        }

        func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?) {
            guard let endpoint = self.endpoint(userData), let endpointURL = endpoint.url else {
                block?(DataFeedError.invalidUrl, nil)
                return
            }

            if let cached: T = self.cache.value(for: endpointURL.absoluteString) {
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
                        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX" // 2019-10-17T06:38:04.993563079Z
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
                    print(String(data: data, encoding: .utf8) ?? "")

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
}

extension DataFeedOneTimePurchase {
    var paid: Bool {
        return oneTime.purchased
    }

    var owned: Bool {
        if userKey != nil {
            return true
        }

        return paid
    }

    var defaultProduct: SKProduct? {
        guard let product = self.oneTime.product else {
            retrieve()
            return nil
        }
        return product
    }

    func restore(completion block: ((RestoreResults) -> Void)? = nil) {
        oneTime.restore(completion: block)
    }

    func verify(completion block: ((Error?) -> Void)? = nil) {
        oneTime.verifyPurchase(completion: block)
    }

    func retrieve(completion block: ((Error?) -> Void)? = nil) {
        oneTime.retrieveProduct(completion: block)
    }
}
