//
//  WhoisXml.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/10/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

/// API wrapper for https://whoisxmlapi.com/
final class WhoisXml: DataFeedSingleton, DataFeedOneTimePurchase {
    public let name: String = "Whois XML API"
    public var webpage: URL { return URL(string: "https://www.whoisxmlapi.com/")! }

    public var userKey: ApiKey? {
        didSet {
            if let key = self.userKey {
                UserDefaults.standard.set(key.key, forKey: UserDefaults.NetUtils.Keys.keyFor(dataFeed: self))
                UserDefaults.standard.synchronize()
            }
        }
    }

    public static var current: WhoisXml = {
        let retVal = WhoisXml()
        if let key = UserDefaults.standard.string(forKey: UserDefaults.NetUtils.Keys.keyFor(dataFeed: retVal)) {
            retVal.userKey = ApiKey(name: retVal.name, key: key)
        }
        return retVal
    }()

    /// The API Key for Whois XML API
    /// - Callout(Default):
    /// `ApiKey.WhoisXML`
    internal var key: ApiKey = ApiKey.WhoisXML

    /// Session used to create tasks
    ///
    /// - Callout(Default):
    /// `URLSession.shared`
    static var session = URLSession.shared

    public var subscriptions: [Subscription] = {
        let monthly = Subscription("whois.monthly.auto")
        let yearly = Subscription("whois.yearly.auto")

        return [monthly, yearly]
    }()

    var oneTime: OneTimePurchase = OneTimePurchase("whois.onetime")
}

// MARK: - Endpoints

extension WhoisXml {
    typealias Endpoints = Endpoint
    /// A URL endpoint
    /// - SeeAlso:
    /// [Constructing URLs in Swift](https://www.swiftbysundell.com/posts/constructing-urls-in-swift)
    class Endpoint: DataFeedEndpoint {
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

        /// https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=#&domainName=google.com
        static func whoisUrl(_ domain: String, with key: String = ApiKey.WhoisXML.key) -> URL? {
            guard let domain = domain.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return nil
            }

            return Endpoint(host: "www.whoisxmlapi.com", path: "/whoisserver/WhoisService", queryItems: [
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

            return Endpoint(host: "www.whoisxmlapi.com", path: "/whoisserver/DNSService", queryItems: [
                URLQueryItem(name: "domainName", value: domain),
                URLQueryItem(name: "apiKey", value: key),
                URLQueryItem(name: "outputFormat", value: "JSON"),
                URLQueryItem(name: "type", value: "_all")
            ]).url
        }
    }
}

// MARK: - DataFeedService

extension WhoisXml: DataFeedService {
    static var whoisService: WhoisXMLService = {
        WhoisXMLService(name: "WHOIS", id: "1")
    }()

    static var dnsService: WhoisXMLService = {
        WhoisXMLDnsService(name: "DNS", id: "26")
    }()

    var services: [Service] {
        let reputation = WhoisXMLService(name: "Reputation", id: "20")

        return [WhoisXml.whoisService, WhoisXml.dnsService, reputation]
    }
}

// MARK: - DataFeedSubscription

extension WhoisXml: DataFeedSubscription {
    /// IF the user has access to the API feed
    ///
    /// We assume access if a user key is set
    var owned: Bool {
        if userKey != nil {
            return true
        }

        return paid
    }

    /// If the current user has subscribed to the WHOIS API
    /// - Important:
    /// This will give you the cached version, use `verifySubscription` to get the asyncronous version
    var paid: Bool {
        #if DEBUG
            if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
                return true
            }
        #endif

        if subscriptions.first(where: { $0.isSubscribed }) != nil {
            return true
        }

        return oneTime.purchased
    }

    var defaultProduct: SKProduct? {
        guard let product = self.subscriptions[0].product else {
            retrieve()
            return nil
        }
        return product
    }

    func restore(completion block: ((RestoreResults) -> Void)? = nil) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            self.subscriptions[0].restore { _ in
                self.subscriptions[1].restore { _ in
                    self.oneTime.restore { _ in
                        block?(results)
                    }
                }
            }
        }
    }

    func verify(completion block: ((Error?) -> Void)? = nil) {
        subscriptions[0].verifySubscription { error in
            guard error == nil else {
                block?(error)
                return
            }
            self.subscriptions[1].verifySubscription { errorTwo in
                guard errorTwo == nil else {
                    block?(errorTwo)
                    return
                }
                self.oneTime.verifyPurchase { errorThree in
                    block?(errorThree)
                }
            }
        }
    }

    func retrieve(completion block: ((Error?) -> Void)? = nil) {
        subscriptions[0].retrieveProduct { error in
            guard error == nil else {
                block?(error)
                return
            }

            self.subscriptions[1].retrieveProduct { errorTwo in
                guard errorTwo == nil else {
                    block?(errorTwo)
                    return
                }

                self.oneTime.retrieveProduct { errorThree in
                    block?(errorThree)
                }
            }
        }
    }
}
