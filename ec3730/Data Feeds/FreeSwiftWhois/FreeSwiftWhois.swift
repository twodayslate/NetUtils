//
//  FreeSwiftWhois.swift
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
import SwiftWhois

final class FreeSwiftWhois: DataFeedSingleton {
    var name: String = "Simple Whois Lookup"

    var webpage: URL = .init(string: "https://zac.gorak.us/")!

    public var userKey: String?

    public static var current: FreeSwiftWhois = .init()

    static var session = URLSession.shared

    var services: [Service] = {
        [FreeSwiftWhois.lookupService]
    }()
    
}

extension FreeSwiftWhois: DataFeedService {
    var totalUsage: Int {
        services.reduce(0) { $0 + $1.usage }
    }

    public static var lookupService: IPLookupService = .init()

    class IPLookupService: Service {
        var name: String = "Simple Whois Lookup"
        var description = "Simple Whois Lookup"

        var cache = TimedCache(expiresIn: 60)

        func endpoint(_: [String: Any?]?) -> DataFeedEndpoint? {
            nil
        }

        func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?) async {
            guard let host = userData?["host"] as? String else {
                block?(URLError(.badURL), nil)
                return
            }
      

                do {
                    guard let  swiftWhoisData =  try await SwiftWhois.lookup(domain: host)  else  {
                        block?(URLError(.badURL), nil)
                        return
                    }
                    
                    block?(nil,  swiftWhoisData as? T)
                }
            catch {
                    block?(error, nil)
                }
            
        }
        func query<T: Codable>(_ userData: [String: Any?]?) async throws -> T {
            guard let host = userData?["host"] as? String else {
                throw URLError(.badURL)
            }

            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    do {
                        guard let swiftWhoisData = try await SwiftWhois.lookup(domain: host) else {
                            continuation.resume(throwing: URLError(.badURL))
                            return
                        }
                       
                        let  dataModel = FreeSwiftWhoisDataModel(from: swiftWhoisData)
                        continuation.resume(returning: dataModel as! T)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

    }
}
