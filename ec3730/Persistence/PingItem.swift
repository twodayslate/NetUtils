import Foundation
import SwiftyPing
import CoreData

extension PingError {
    var localizedDescription: String {
        switch self {
        case .addressLookupError:
            return "Address lookup failed."
        case .addressMemoryError:
            return "Address data could not be converted to `sockaddr`."
        case .checksumMismatch(_,_):
            return "The received checksum doesn't match the calculated one."
        case .checksumOutOfBounds:
            return "Checksum is out-of-bounds for `UInt16` in `computeCheckSum`."
        case .hostNotFound:
            return "Host was not found."
        case .identifierMismatch(_,_):
            return "Response `identifier` doesn't match what was sent."
        case .invalidCode(_):
            return "Response `code` was invalid."
        case .invalidHeaderOffset:
            return "The ICMP header offset couldn't be calculated."
        case .invalidLength(_):
            return "The response length was too short."
        case .invalidSequenceIndex(_,_):
            return "Response `sequenceNumber` doesn't match."
        case .invalidType(_):
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
        case .socketOptionsSetError(_):
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
    
    convenience init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "PingSet", in: context) else {
            fatalError("No entity named PingSet")
        }
        self.init(entity: entity, insertInto: context)
        self.timestamp = Date()
        self.pings = Set()
    }
}

extension PingSet {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func fetchAllRequest() -> NSFetchRequest<PingSet> {
        let request: NSFetchRequest<PingSet> = PingSet.fetchRequest() as! NSFetchRequest<PingSet>
        
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
        
        self.identifier = response.identifier
        self.sequenceNumber = response.sequenceNumber
        if let error = response.error {
            self.error = error.localizedDescription
        }
        if let duration = response.duration {
            self.duration = duration
        }
        if let ipAddress = response.ipAddress {
            self.ipAddress = ipAddress
        }
        
        self.timestamp = Date()
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
