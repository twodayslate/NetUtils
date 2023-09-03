import AddressURL
import CloudKit
import CoreData
import Foundation
import KeychainAccess
import StoreKit
import SwiftyStoreKit

final class URLParsedFeed: DataFeedSingleton {
    var name: String = "Parse URL"

    var webpage: URL = .init(string: "https://zac.gorak.us/")!

    public var userKey: String?

    public static var current: URLParsedFeed = .init()

    static var session = URLSession.shared

    var services: [Service] = {
        [URLParsedFeed.lookupService]
    }()
}

extension URLParsedFeed: DataFeedService {
    var totalUsage: Int {
        services.reduce(0) { $0 + $1.usage }
    }

    public static var lookupService: URLLookupService = .init()

    class URLLookupService: Service {
        var name: String = "Parse URL"
        var description = "Parse URL"

        func endpoint(_: [String: Any?]?) -> DataFeedEndpoint? {
            nil
        }

        func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?) {
            guard let host = userData?["url"] as? T else {
                block?(URLError(.badURL), nil)
                return
            }

            block?(nil, host)
        }

        func query<T: Codable>(_ userData: [String: Any?]?) async throws -> T {
            guard let host = userData?["url"] as? T else {
                throw URLError(.badURL)
            }

            return host
        }
    }
}
