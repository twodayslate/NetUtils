import CoreData

public class HostData: NSManagedObject {
    @NSManaged public var service: String
    @NSManaged public var data: Data
    @NSManaged public var date: Date

    convenience init(context: NSManagedObjectContext, service: Service, data: Data) {
        guard let entity = NSEntityDescription.entity(forEntityName: "HostDataEntity", in: context) else {
            fatalError("No entity named HostData")
        }
        self.init(entity: entity, insertInto: context)

        self.service = service.name
        self.data = data
        date = Date()
    }
}
