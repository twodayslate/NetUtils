//
//  WhoisDns.swift
//  ec3730
//
//  Created by Upwork on 17/01/24.
//  Copyright © 2024 Zachary Gorak. All rights reserved.
//

import Foundation
import AddressURL
import CloudKit
import CoreData
import Foundation
import KeychainAccess
import StoreKit
import SwiftyStoreKit

final class WhoisDns: DataFeedSingleton {
    var name: String = "Simple IP Lookup"

    var webpage: URL = .init(string: "https://zac.gorak.us/")!

    public var userKey: String?

    public static var current: WhoisDns = .init()

    static var session = URLSession.shared

    var services: [Service] = {
        [WhoisDns.lookupService]
    }()
}

extension WhoisDns: DataFeedService {
    var totalUsage: Int {
        services.reduce(0) { $0 + $1.usage }
    }

    public static var lookupService: IPLookupService = .init()

    class IPLookupService: Service {
        var name: String = "Simple IP Lookup"
        var description = "Simple IP Lookup"

        var cache = TimedCache(expiresIn: 60)

        func endpoint(_: [String: Any?]?) -> DataFeedEndpoint? {
            nil
        }

        func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?) {
            guard let host = userData?["host"] as? String else {
                block?(URLError(.badURL), nil)
                return
            }

            DNSResolver.resolve(host: host) { error, addresses in
                guard error == nil else {
                    block?(error, nil)
                    return
                }
                guard let addresses = addresses as? T else {
                    block?(URLError(.badURL), nil)
                    return
                }

                block?(nil, addresses)
            }
        }

        func query<T: Codable>(_ userData: [String: Any?]?) async throws -> T {
            guard let host = userData?["host"] as? String else {
                throw URLError(.badURL)
            }

            return try await withCheckedThrowingContinuation { continuation in
                DNSResolver.resolve(host: host) { error, addresses in
                    if let error {
                        continuation.resume(with: .failure(error))
                        return
                    }
                    guard let addresses = addresses as? T else {
                        continuation.resume(with: .failure(URLError(.badURL)))
                        return
                    }

                    continuation.resume(with: .success(addresses))
                }
            }
        }
    }
}
