//
//  Monapi.swift
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
import AddressURL

final class Monapi: DataFeedSingleton, DataFeedOneTimePurchase {
    var name: String = "monapi.io"

    var webpage: URL = URL(string: "https://www.monapi.io/")!

    public var userKey: String? {
        didSet {
            let keychian = Keychain().synchronizable(true)
            if let key = self.userKey {
                try? keychian.set(key, key: UserDefaults.NetUtils.Keys.keyFor(dataFeed: self))
            } else {
                try? keychian.remove(UserDefaults.NetUtils.Keys.keyFor(dataFeed: self))
            }
        }
    }

    public static var current: Monapi = {
        let retVal = Monapi()
        let keychian = Keychain().synchronizable(true)
        if let key = try? keychian.get(UserDefaults.NetUtils.Keys.keyFor(dataFeed: retVal)) {
            retVal.userKey = key
        }
        return retVal
    }()

    static var session = URLSession.shared

    public var subscriptions: [Subscription] = {
        let monthly = Subscription("monapi.monthly.auto")
        let yearly = Subscription("monapi.yearly.auto")

        return [monthly, yearly]
    }()

    var oneTime: OneTimePurchase = OneTimePurchase("monapi.onetime")

    var services: [Service] = {
        [Monapi.lookupService]
    }()
}

// MARK: - Endpoints

extension Monapi {
    typealias Endpoints = Endpoint

    //swiftlint:disable identifier_name
    /** https://www.monapi.io/blacklists/ */
    enum FeedResource: String, Codable {
         case ASPROX_TRACKER = "ASPROX TRACKER"
         case ABUSE_CH_BADIPS = "ABUSE.CH BADIPS"
         case ABUSE_CH_FEODO = "ABUSE.CH FEODO"
         case ABUSE_CH_GREENSNOW = "ABUSE.CH GREENSNOW"
         case ABUSE_CH_SSLBL = "ABUSE.CH SSLBL"
         case ABUSE_CH_ZEUS_BADIPS = "ABUSE.CH ZEUS_BADIPS"
         case ALIENVAULT = "ALIENVAULT"
         case BAMBENEK_BANJORI = "BAMBENEK - BANJORI"
         case BAMBENEK_BEBLOH = "BAMBENEK - BEBLOH"
         case BAMBENEK_C2 = "BAMBENEK - C2"
         case BAMBENEK_CRYPTOWALL = "BAMBENEK - CRYPTOWALL"
         case BAMBENEK_DIRCRYPT = "BAMBENEK - DIRCRYPT"
         case BAMBENEK_DYRE = "BAMBENEK - DYRE"
         case BAMBENEK_GEODO = "BAMBENEK - GEODO"
         case BAMBENEK_HESPERBOT = "BAMBENEK - HESPERBOT"
         case CHARLES_HALEY = "CHARLES HALEY"
         case DSHIELD_ORG_TOP_1000 = "DSHIELD.ORG TOP_1000"
         case DATAPLANE_DNSRD = "DATAPLANE DNSRD"
         case DATAPLANE_DNSRDANY = "DATAPLANE DNSRDANY"
         case DATAPLANE_DNSVERSION = "DATAPLANE DNSVERSION"
         case DATAPLANE_SIPINVITATION = "DATAPLANE SIPINVITATION"
         case SPAMHOUSE_ORG_DROP = "SPAMHOUSE.ORG DROP"
         case TALOSINTEL_COM = "TALOSINTEL.COM"
         case THREAT_CROWD = "THREAT CROWD"
         case TURRIS = "TURRIS"
         case BLOCKLIST_DE = "BLOCKLIST_DE"
         case BLOCKLIST_DE_APACHE = "BLOCKLIST_DE_APACHE"
         case BLOCKLIST_DE_BOTS = "BLOCKLIST_DE_BOTS"
         case BLOCKLIST_DE_BRUTEFORCE = "BLOCKLIST_DE_BRUTEFORCE"
         case BLOCKLIST_DE_FTP = "BLOCKLIST_DE_FTP"
         case BLOCKLIST_DE_IMAP = "BLOCKLIST_DE_IMAP"
         case BLOCKLIST_DE_MAIL = "BLOCKLIST_DE_MAIL"
         case BLOCKLIST_DE_SIP = "BLOCKLIST_DE_SIP"
         case BLOCKLIST_DE_SSH = "BLOCKLIST_DE_SSH"
         case BLOCKLIST_DE_STRONGIPS = "BLOCKLIST_DE_STRONGIPS"
         case BLOCKLIST_NET_UA = "BLOCKLIST_NET_UA"
         case DANGER_RULEZ_SK_BRUTEFORCEBLOCKER = "DANGER.RULEZ.SK BRUTEFORCEBLOCKER"

         case ABUSE_CH_RANSOMWARE_TRACKER = "ABUSE.CH RANSOMWARE TRACKER"
         case ABUSEAT_CBL = "ABUSEAT CBL"
         case AUTOSHUN_ORG = "AUTOSHUN.ORG"
         case BARRACUDA_REPUTATION_BLOCK_LIST = "BARRACUDA REPUTATION BLOCK LIST"
         case CASA = "CASA"
         case CIARMY = "CIARMY"
         case CRUZIT_COM = "CRUZIT.COM"
         case CYBER_THREAT_ALLIANCE = "CYBER THREAT ALLIANCE"
         case CYBERCRIME = "CYBERCRIME"
         case CYMRU_BOGOS = "CYMRU BOGOS"
         case DYNDNS_ORG = "DYNDNS.ORG"
         case EMERGING_THREATS_BOT = "EMERGING THREATS BOT"
         case EMERGING_THREATS_COMPROMISED = "EMERGING THREATS COMPROMISED"
         case EMERGING_THREATS_TOR = "EMERGING THREATS TOR"
         case GPF_COMICS = "GPF COMICS"
         case MYIP_MS = "MYIP.MS"
         case NOTHINK_ORG_DNS_BLACKLIST = "NOTHINK.ORG DNS BLACKLIST"
         case PACKETMAIL_NET = "PACKETMAIL.NET"
         case SNORT_ORG_LABS = "SNORT.ORG LABS"
         case SPAMCOP_BLOCKING_LIST_SCBL = "SPAMCOP BLOCKING LIST (SCBL)"
         case SPAMHOUSE_ORG_EDROP = "SPAMHOUSE.ORG EDROP"
         case TAICHUNG_EDUCATION_CENTER = "TAICHUNG EDUCATION CENTER"
         case THE_LASHBACK_UNSUBSCRIBE_BLACKLIST = "THE LASHBACK UNSUBSCRIBE BLACKLIST"
         case TORPROJECT_ORG = "TORPROJECT.ORG"
         case TRUSTEDSEC = "TRUSTEDSEC"
         case WOODY_S_SMTP_BLACKLIST = "WOODY'S SMTP BLACKLIST"
         case DAN_ME_UK = "DAN.ME.UK"
         case DARKLIST_DE = "DARKLIST.DE"
         case HPHOSTS_ATS = "HPHOSTS ATS"
         case MALC0DE_COM = "MALC0DE.COM"
         case MALWAREDOMAINLIST = "MALWAREDOMAINLIST"
         case NIXSPAM = "NIXSPAM"
         case NULLSECURE = "NULLSECURE"
         case NULLSECURE_ORG = "NULLSECURE.ORG"

         case MSRBL_PHISHING = "MSRBL PHISHING"
         case MSRBL_SPAM = "MSRBL SPAM"
         case MSRBL_VIRUS = "MSRBL VIRUS"
         case MSRBL_COMBINED = "MSRBL COMBINED"
         case PHISHTANK = "PHISHTANK"
         case RATS_DYNA = "RATS-DYNA"
         case RATS_NOPTR = "RATS-NOPTR"
         case RATS_SPAM = "RATS-SPAM"
         case SORBS_DUL = "SORBS DUL"
         case SORBS_HTTP = "SORBS HTTP"
         case SORBS_MISC = "SORBS MISC"
         case SORBS_NEW_SPAM = "SORBS NEW SPAM"
         case SORBS_PROXY = "SORBS PROXY"
         case SORBS_RECENT_SPAM = "SORBS RECENT SPAM"
         case SORBS_SMTP = "SORBS SMTP"
         case SORBS_SPAM = "SORBS SPAM"
         case SORBS_WEB = "SORBS WEB"
         case SORBS_ZOMBIES = "SORBS ZOMBIES"
         case SORBS_BADCONF = "SORBS BADCONF"
         case STOPFORUMSPAM = "STOPFORUMSPAM"
         case UCEPROTECT_LEVEL_1 = "UCEPROTECT LEVEL 1"
         case UCEPROTECT_LEVEL_2 = "UCEPROTECT LEVEL 2"
         case UCEPROTECT_LEVEL_3 = "UCEPROTECT LEVEL 3"
         case WPBL = "WPBL"
         case INPS_DE_DNS_IP_BLACKLIST = "INPS.DE DNS IP BLACKLIST"

        //swiftlint:enable identifier_name
        
        var description: String {
            switch self {
            default:
                return "Unknown"
            }
        }
        
        var maintainer: URL {
            switch self {
            case .SORBS_WEB, .SORBS_MISC, .SORBS_SMTP, .SORBS_SPAM, .SORBS_ZOMBIES, .SORBS_BADCONF, .SORBS_HTTP, .SORBS_DUL:
                return URL(string: "http://www.sorbs.net/")!
            case .UCEPROTECT_LEVEL_1, .UCEPROTECT_LEVEL_2, .UCEPROTECT_LEVEL_3:
                return URL(string: "http://www.uceprotect.net/")!
            case .WPBL:
                return URL(string: "http://www.wpbl.info/")!
            case .INPS_DE_DNS_IP_BLACKLIST:
                return URL(string: "http://http://dnsbl.inps.de/")!
            default:
                return URL(string: "https://www.monapi.io/blacklists/")!
            }
        }
    }

    /// A URL endpoint
    /// - SeeAlso:
    /// [Constructing URLs in Swift](https://www.swiftbysundell.com/posts/constructing-urls-in-swift)
    class Endpoint: DataFeedEndpoint {

        static func domain(address: String, with key: String? = nil) -> Endpoint? {
            var threatItems = [
                URLQueryItem(name: "api", value: "monapi"),
                URLQueryItem(name: "identifierForVendor", value: UIDevice.current.identifierForVendor?.uuidString),
                URLQueryItem(name: "bundleIdentifier", value: Bundle.main.bundleIdentifier)
            ]

            if let key = Monapi.current.userKey {
                threatItems.append(URLQueryItem(name: "userKey", value: key))
            }

            return Endpoint(host: "api.netutils.workers.dev",
                            path: "/v1/domain/" + address, queryItems: threatItems)
        }
        
        static func ip(address: String, with key: String? = nil) -> Endpoint? {
            var threatItems = [
                URLQueryItem(name: "api", value: "monapi"),
                URLQueryItem(name: "identifierForVendor", value: UIDevice.current.identifierForVendor?.uuidString),
                URLQueryItem(name: "bundleIdentifier", value: Bundle.main.bundleIdentifier)
            ]

            if let key = Monapi.current.userKey {
                threatItems.append(URLQueryItem(name: "userKey", value: key))
            }

            return Endpoint(host: "api.netutils.workers.dev",
                            path: "/v1/ip/" + address, queryItems: threatItems)
        }
    
        static func email(address: String, with key: String? = nil) -> Endpoint? {
            var threatItems = [
                URLQueryItem(name: "api", value: "monapi"),
                URLQueryItem(name: "identifierForVendor", value: UIDevice.current.identifierForVendor?.uuidString),
                URLQueryItem(name: "bundleIdentifier", value: Bundle.main.bundleIdentifier)
            ]

            if let key = Monapi.current.userKey {
                threatItems.append(URLQueryItem(name: "userKey", value: key))
            }

            return Endpoint(host: "api.netutils.workers.dev",
                            path: "/v1/email/" + address, queryItems: threatItems)
        }
    }
}

// MARK: - DataFeedService

extension Monapi: DataFeedService {
    var totalUsage: Int {
        return services.reduce(0) { $0 + $1.usage }
    }

    public static var lookupService: IPLookupService = {
        IPLookupService()
    }()

    class IPLookupService: Service {
        var name: String = "monapi.io"

        var cache = TimedCache(expiresIn: 60)

        func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint? {
            guard let uri = userData?["uri"] as? URL else {
                return nil
            }
            
            if let address = uri.emailAddress {
                return Monapi.Endpoints.email(address: address)
            }
            
            if let address = uri.ipv4Address {
                return Monapi.Endpoints.ip(address: "\(address)")
            }

            if let address = uri.ipv6Address {
                return Monapi.Endpoints.ip(address: "\(address)")
            }
            
            if let address = uri.hostname {
                 return Monapi.Endpoints.domain(address: address)
            }
            
            if let address = uri.host {
                 return Monapi.Endpoints.domain(address: address)
            }
            
            return nil
        }

        func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?) {
            guard let endpoint = self.endpoint(userData) else {
                block?(DataFeedError.invalidUrl, nil)
                return
            }
            guard let endpointURL = endpoint.url else {
                block?(DataFeedError.invalidUrl, nil)
                return
            }

            usage += 1

            if let cached: T = self.cache.value(for: endpointURL.absoluteString) {
                block?(nil, cached)
                return
            }
            
            Monapi.session.dataTask(with: endpointURL) { data, _, error in
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
                    // print(String(decoding: data, as: UTF8.self))
                    let coordinator = try decoder.decode(T.self, from: data)
                    print(coordinator)
                    
                    // only cache if there is no
                    if let msg = coordinator as? MonapiThreat {
                        if msg.error == nil, msg.detail == nil {
                            self.cache.add(coordinator, for: endpointURL.absoluteString)
                        }
                    } else {
                        self.cache.add(coordinator, for: endpointURL.absoluteString)
                    }

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

// MARK: - DataFeedSubscription

extension Monapi: DataFeedSubscription {
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
            for failed in results.restoreFailedPurchases {
                print(failed.0, failed.1 ?? "")
            }
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
