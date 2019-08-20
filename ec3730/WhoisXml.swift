//
//  WhoisXml.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/10/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit

/// API wrapper for https://whoisxmlapi.com/
class WhoisXml {
    // MARK: - Properties

    /// The API Key for Whois XML API
    /// - Callout(Default):
    /// `ApiKey.WhoisXML`
    public static let api: ApiKey = ApiKey.WhoisXML
    /// Session used to create tasks
    ///
    /// - Callout(Default):
    /// `URLSession.shared`
    public static var session = URLSession.shared
    private static var _cachedExpirationDate: Date?

    public enum Subscriptions {
        /// Auto-renewable Monthly Subscription
        case monthly

        /// Product identifier
        var identifier: String {
            switch self {
            default:
                return "whois.monthly.auto"
            }
        }

        /// - parameters:
        ///   - subscription: the subscription to get the localized price for
        ///   - block: completion block containing possible errors and/or the
        ///            localized price of the `subscription`
        public func retrieveLocalizedPrice(for subscription: Subscriptions = .monthly, completion block: ((String?, Error?) -> Void)? = nil) {
            SwiftyStoreKit.retrieveProductsInfo([subscription.identifier]) { result in
                guard result.error == nil else {
                    block?(nil, result.error)
                    return
                }
                if let product = result.retrievedProducts.first {
                    block?(product.localizedPrice, nil)
                } else if let invalidProductId = result.invalidProductIDs.first {
                    block?(nil, WhoisXmlError.invalidProduct(id: invalidProductId))
                }
            }
        }
    }

    enum Service {
        case whois
        case dns
        case reputation

        var id: String {
            switch self {
            case .whois:
                return "1"
            case .dns:
                return "26"
            case .reputation:
                return "20"
            }
        }
        
        static var cache = [String: TimedCache]()
        
        var cache: TimedCache {
            if let currentCache = Service.cache[self.id] {
                return currentCache
            }
            Service.cache[self.id] = TimedCache(expiresIn: 300)
            return Service.cache[self.id]!
        }

        func url(_ domain: String, key: String = ApiKey.WhoisXML.key) -> URL? {
            switch self {
            case .whois:
                return Endpoint.whoisUrl(domain, with: key)
            case .dns:
                return Endpoint.dnsUrl(domain, with: key)
            case .reputation:
                return nil
            }
        }

        func balance(key: String = ApiKey.WhoisXML.key, completion block: ((Error?, Int?) -> Void)? = nil) {
            guard let balanceURL = Endpoint.balanceUrl(for: self.id, with: key) else {
                block?(WhoisXmlError.invalidUrl, nil) // TODO: set error
                return
            }

            WhoisXml.session.dataTask(with: balanceURL) { data, _, error in
                guard error == nil else {
                    block?(error, nil)
                    return
                }
                guard let data = data else {
                    block?(WhoisXmlError.empty, nil)
                    return
                }

                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    block?(WhoisXmlError.parse, nil) // TODO: set error
                    return
                }

                guard let jsonDataArray = json["data"] as? [Any?], jsonDataArray.count == 1, let first = jsonDataArray[0] as? [String: Any?], let balance = first["credits"] as? Int else {
                    block?(WhoisXmlError.parse, nil) // TODO: set error
                    return
                }

                block?(nil, balance)
            }.resume()
        }
    }

    /// If the current user has subscribed to the WHOIS API
    /// - Important:
    /// This will give you the cached version, use `verifySubscription` to get the asyncronous version
    public class var isSubscribed: Bool {
        verifySubscription()

        guard let expiration = _cachedExpirationDate else {
            return false
        }

        return expiration.timeIntervalSinceNow > 0
    }

    class func verifySubscription(for subscription: Subscriptions = .monthly, completion block: ((Error?, VerifySubscriptionResult?) -> Void)? = nil) {
        guard let _ = SwiftyStoreKit.localReceiptData else {
            block?(nil, VerifySubscriptionResult.notPurchased)
            return
        }
        let validator = AppleReceiptValidator(service: .production, sharedSecret: ApiKey.inApp.key)
        SwiftyStoreKit.verifyReceipt(using: validator) { result in
            switch result {
            case let .success(receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: Set([subscription.identifier]), inReceipt: receipt)

                block?(nil, purchaseResult)

                switch purchaseResult {
                case let .purchased(expiryDate, items):
                    print("subscription is valid until \(expiryDate)\n\(items)\n")
                    _cachedExpirationDate = expiryDate
                case let .expired(expiryDate, items):
                    print("subscription is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased subscription")
                }

            case let .error(error):
                print("Receipt verification failed: \(error)")
                block?(error, nil)
            }
        }
    }

    /// A URL endpoint
    /// - SeeAlso:
    /// [Constructing URLs in Swift](https://www.swiftbysundell.com/posts/constructing-urls-in-swift)
    struct Endpoint {
        let schema: String
        let host: String
        var path: String = ""
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: ApiKey.WhoisXML.key)
        ]

        init(schema: String = "https", host: String = "www.whoisxmlapi.com", path: String = "", queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: ApiKey.WhoisXML.key)
        ]) {
            self.schema = schema
            self.host = host
            self.path = path
            self.queryItems = queryItems
        }

        func with(schema: String? = nil, host: String? = nil, path: String? = nil, queryItems: [URLQueryItem]? = nil) -> Endpoint {
            return Endpoint(schema: schema ?? self.schema, host: host ?? self.host, path: path ?? self.path, queryItems: queryItems ?? self.queryItems)
        }

        var url: URL? {
            var components = URLComponents()
            components.scheme = schema
            components.host = host
            components.path = path
            components.queryItems = queryItems
            return components.url
        }

        /// OLD https://www.whoisxmlapi.com/accountServices.php?servicetype=accountbalance&apiKey=#
        /// NEW https://user.whoisxmlapi.com/service/account-balance?productId=1&apiKey=#
        static func balanceUrl(for id: String = "1", with key: String = ApiKey.WhoisXML.key) -> URL? {
            return Endpoint(host: "user.whoisxmlapi.com",
                            path: "/service/account-balance", queryItems: [
                                URLQueryItem(name: "productId", value: id),
                                URLQueryItem(name: "apiKey", value: key),
                                URLQueryItem(name: "output_format", value: "JSON")
                            ]).url
        }

        /// https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=at_QdHCML5OhryN0g2sHBeesD8aVNmMS&domainName=google.com
        static func whoisUrl(_ domain: String, with key: String = ApiKey.WhoisXML.key) -> URL? {
            guard let domain = domain.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return nil
            }

            return Endpoint(path: "/whoisserver/WhoisService", queryItems: [
                URLQueryItem(name: "domainName", value: domain),
                URLQueryItem(name: "apiKey", value: key),
                URLQueryItem(name: "outputFormat", value: "JSON"),
                URLQueryItem(name: "da", value: "2"),
                URLQueryItem(name: "ip", value: "1")
            ]).url
        }

        /// https://www.whoisxmlapi.com/whoisserver/DNSService?apiKey=#&domainName=bbc.com&type=1
        static func dnsUrl(_ domain: String, with key: String = ApiKey.WhoisXML.key) -> URL? {
            guard let domain = domain.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return nil
            }

            return Endpoint(path: "/whoisserver/DNSService", queryItems: [
                URLQueryItem(name: "domainName", value: domain),
                URLQueryItem(name: "apiKey", value: key),
                URLQueryItem(name: "outputFormat", value: "JSON"),
                URLQueryItem(name: "type", value: "_all")
            ]).url
        }
    }
}

extension WhoisXml {
    public class func query<T: Decodable>(_ domain: String, service: WhoisXml.Service, key: String = ApiKey.WhoisXML.key, minimumBalance: Int = 100, completion block: ((Error?, T?) -> Void)? = nil) {
        guard let queryUrl = service.url(domain, key: key) else {
            block?(WhoisXmlError.invalidUrl, nil) // TODO: return error

            return
        }
        
        if let cached: T = service.cache.value(for: queryUrl.absoluteString) {
            block?(nil, cached)
        }
    
        service.balance { error, balance in
            guard error == nil else {
                block?(error, nil)
                return
            }

            guard let balance = balance else {
                block?(WhoisXmlError.nil, nil) // TODO: set error
                return
            }

            guard balance > minimumBalance else {
                block?(WhoisXmlError.lowBalance(balance: balance), nil) // TODO: set error
                return
            }

            WhoisXml.session.dataTask(with: queryUrl) { data, _, error in
                guard error == nil else {
                    block?(error, nil)
                    return
                }
                guard let data = data else {
                    block?(WhoisXmlError.empty, nil)
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
                        "yyyy-MM-dd HH:mm:ss ZZZ" // 1997-09-15 07:00:00 UTC
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
                    service.cache.add(coordinator, for: queryUrl.absoluteString)
                    block?(nil, coordinator)
                } catch let decodeError {
                    print(decodeError)
                    print(String(data: data, encoding: .utf8) ?? "")
                    block?(decodeError, nil)
                }
            }.resume()
        }
    }

    public class func whoisQuery(_ domain: String, key: String = ApiKey.WhoisXML.key, minimumBalance: Int = 100, completion block: ((Error?, WhoisRecord?) -> Void)? = nil) {
        query(domain, service: .whois, key: key, minimumBalance: minimumBalance, completion: { (error, record: Coordinate?) in
            block?(error, record?.whoisRecord)
        })
    }
}
