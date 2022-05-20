import AddressURL
import CloudKit
import CoreData
import Foundation
import KeychainAccess
import StoreKit
import SwiftyStoreKit

final class LocalDns: DataFeedSingleton {
    var name: String = "Simple IP Lookup"

    var webpage: URL = .init(string: "https://zac.gorak.us/")!

    public var userKey: String?

    public static var current: LocalDns = .init()

    static var session = URLSession.shared

    var services: [Service] = {
        [LocalDns.lookupService]
    }()
}

extension LocalDns: DataFeedService {
    var totalUsage: Int {
        return services.reduce(0) { $0 + $1.usage }
    }

    public static var lookupService: IPLookupService = .init()

    class IPLookupService: Service {
        var name: String = "Simple IP Lookup"
        var description = "Simple IP Lookup"

        var cache = TimedCache(expiresIn: 60)

        func endpoint(_: [String: Any?]?) -> DataFeedEndpoint? {
            return nil
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
    }
}
