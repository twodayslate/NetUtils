//
//  WhoisXml.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/10/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import KeychainAccess
import StoreKit
import SwiftyStoreKit

/// API wrapper for https://whoisxmlapi.com/
final class WhoisXml: DataFeedSingleton, DataFeedOneTimePurchase {
    public let name: String = "Whois XML API"
    public var webpage: URL { URL(string: "https://www.whoisxmlapi.com/")! }

    public var userKey: String? {
        didSet {
            // Save the key to the keychain

            let keychian = Keychain().synchronizable(true)
            if let key = userKey {
                try? keychian.set(key, key: UserDefaults.NetUtils.Keys.keyFor(dataFeed: self))
            } else {
                try? keychian.remove(UserDefaults.NetUtils.Keys.keyFor(dataFeed: self))
            }
        }
    }

    public static var current: WhoisXml = {
        let retVal = WhoisXml()

        let keychian = Keychain().synchronizable(true)
        if let key = try? keychian.get(UserDefaults.NetUtils.Keys.keyFor(dataFeed: retVal)) {
            retVal.userKey = key
        }
        return retVal
    }()

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

    var oneTime: OneTimePurchase = .init("whois.onetime")
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
        static func balanceUrl(for id: String, with key: String?) -> URL? {
            var params = [
                URLQueryItem(name: "productId", value: id),
                URLQueryItem(name: "output_format", value: "JSON"),
                URLQueryItem(name: "identifierForVendor", value: UIDevice.current.identifierForVendor?.uuidString),
                URLQueryItem(name: "api", value: "whoisXmlBalance"),
            ]

            if let bundle = Bundle.main.bundleIdentifier {
                params.append(URLQueryItem(name: "bundleIdentifier", value: bundle))
            }

            if let key = key {
                params.append(URLQueryItem(name: "apiKey", value: key))
            }

            return Endpoint(host: "api.netutils.workers.dev",
                            path: "/service/account-balance", queryItems: params).url
        }
    }
}

// MARK: - DataFeedService

extension WhoisXml: DataFeedService {
    static var whoisService: WhoisXMLService = .init(name: "WHOIS", description: "Our hosted WHOIS Lookup provides the registration details, also known as a WHOIS Record, of domain names", id: "1")

    static var dnsService: WhoisXMLService = WhoisXMLDnsService(name: "DNS", description: "Our hosted DNS Lookup provides the records associated with a domain", id: "26")

    static var reputationService: WhoisXMLService = .init(name: "Reputation", description: "Our hosted lookup uses hundreds of parameters to calculate reputation scores.", id: "20")

    static var contactsService: WhoisXMLService = WhoisXmlContactsService(
        name: "Contacts",
        description: "Our hosted domain contact information lookup includes company name, direct-dial phone numbers, email addresses, and social media links.",
        id: "29"
    )
    static var CategorizationService: WhoisXMLService = WhoIsXmlCategorizationService(
        name: "Website Categorization",
        description: "Our hosted lookup uses a machine learning (ML) engine to scan a website’s content and meta tags to classify the site.",
        id: "21"
    )

    static var GeoLocationService: WhoisXMLService = WhoIsXmlGeoLocationService(
        name: "Geolocation",
        description: "Our hosted lookup allows you to identify an IP's geographical location which can help prevent fraud, ensure regulatory compliance, and more.",
        id: "8"
    )

    var services: [Service] {
        [
            WhoisXml.whoisService,
            WhoisXml.dnsService,
            WhoisXml.reputationService,
            WhoisXml.contactsService,
            WhoisXml.CategorizationService,
            WhoisXml.GeoLocationService,
        ]
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
        guard let product = subscriptions[0].product else {
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
