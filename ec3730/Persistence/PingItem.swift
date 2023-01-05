import CoreData
import Foundation
import SwiftyPing

extension PingError {
    var localizedDescription: String {
        switch self {
        case .addressLookupError:
            return "Address lookup failed."
        case .addressMemoryError:
            return "Address data could not be converted to `sockaddr`."
        case .checksumMismatch:
            return "The received checksum doesn't match the calculated one."
        case .checksumOutOfBounds:
            return "Checksum is out-of-bounds for `UInt16` in `computeCheckSum`."
        case .hostNotFound:
            return "Host was not found."
        case .identifierMismatch:
            return "Response `identifier` doesn't match what was sent."
        case .invalidCode:
            return "Response `code` was invalid."
        case .invalidHeaderOffset:
            return "The ICMP header offset couldn't be calculated."
        case .invalidLength:
            return "The response length was too short."
        case .invalidSequenceIndex:
            return "Response `sequenceNumber` doesn't match."
        case .invalidType:
            return "Response `type` was invalid."
        case .packageCreationFailed:
            return "Unspecified package creation error."
        case .requestError:
            return "An error occured while sending the request."
        case .requestTimeout:
            return "The request send timed out."
        case .responseTimeout:
            return "The response took longer to arrive than `configuration.timeoutInterval`."
        case .socketNil:
            return "For some reason, the socket is `nil`."
        case .socketOptionsSetError:
            return "Failed to change socket options, in particular SIGPIPE."
        case .unexpectedPayloadLength:
            return "Unexpected payload length."
        case .unknownHostError:
            return "Unknown error occured within host lookup."
        }
    }
}

public class PingSet: NSManagedObject, Identifiable {
    @NSManaged public var timestamp: Date
    @NSManaged public var pings: Set<PingItem>
    @NSManaged public var host: String
    @NSManaged public var ttl: Int
    @NSManaged public var payloadSize: Int

    convenience init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "PingSet", in: context) else {
            fatalError("No entity named PingSet")
        }
        self.init(entity: entity, insertInto: context)
        timestamp = Date()
        pings = Set()
    }

    convenience init(context: NSManagedObjectContext, configuration: PingConfiguration) {
        self.init(context: context)
        ttl = configuration.timeToLive ?? 0
        payloadSize = configuration.payloadSize
    }
}

extension PingSet {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func fetchAllRequest(limit: Int? = nil) -> NSFetchRequest<PingSet> {
        let request: NSFetchRequest<PingSet> = PingSet.fetchRequest() as! NSFetchRequest<PingSet>
        if let limit {
            request.fetchLimit = limit
        }

        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        return request
    }
}

extension PingItem {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func fetchAllRequest() -> NSFetchRequest<PingSet> {
        let request: NSFetchRequest<PingSet> = PingSet.fetchRequest() as! NSFetchRequest<PingSet>

        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        return request
    }
}

public class PingItem: NSManagedObject, Identifiable {
    @NSManaged public var byteCount: Int
    @NSManaged public var identifier: UInt16
    @NSManaged public var sequenceNumber: Int
    @NSManaged public var duration: Double
    @NSManaged public var timestamp: Date
    @NSManaged public var error: String?
    @NSManaged public var ipAddress: String?

    convenience init(context: NSManagedObjectContext, response: PingResponse) {
        guard let entity = NSEntityDescription.entity(forEntityName: "PingItem", in: context) else {
            fatalError("No entity named PingItem")
        }
        self.init(entity: entity, insertInto: context)

        if let byteCount = response.byteCount {
            self.byteCount = byteCount
        }

        identifier = response.identifier
        sequenceNumber = Int(response.sequenceNumber)
        if let error = response.error {
            self.error = error.localizedDescription
        }
        duration = response.duration
        if let ipAddress = response.ipAddress {
            self.ipAddress = ipAddress
        }

        timestamp = Date()
    }
}

extension PingItem {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func fetchAllRequest() -> NSFetchRequest<PingItem> {
        let request: NSFetchRequest<PingItem> = PingItem.fetchRequest() as! NSFetchRequest<PingItem>

        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        return request
    }
}
