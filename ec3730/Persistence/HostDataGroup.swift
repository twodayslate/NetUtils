import CoreData

public class HostDataGroup: NSManagedObject, Identifiable {
    @NSManaged public var date: Date
    @NSManaged public var url: URL
    // would be great if this was an ordered set but obj-c and nsmanaged doesn't like that
    @NSManaged public var results: Set<HostData>
    
    convenience init(context: NSManagedObjectContext, url: URL, data: Set<HostData> = Set<HostData>()) {
        guard let entity = NSEntityDescription.entity(forEntityName: "HostDataGroup", in: context) else {
            fatalError("No entity named HostDataGroup")
        }
        self.init(entity: entity, insertInto: context)
        
        self.results = data
        self.url = url
        self.date = Date()
    }
}

extension HostDataGroup {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func fetchAllRequest() -> NSFetchRequest<HostDataGroup> {
        let request: NSFetchRequest<HostDataGroup> = HostDataGroup.fetchRequest() as! NSFetchRequest<HostDataGroup>
        
        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        return request
    }
}
