//
//  DFService.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import CoreData
import Foundation

protocol Service: AnyObject {
    var name: String { get }
    var description: String { get }
    func endpoint(_ userData: [String: Any?]?) -> DataFeedEndpoint?

    var usage: Int { get set }

    func query<T: Codable>(_ userData: [String: Any?]?, completion block: ((Error?, T?) -> Void)?)
}

extension Service {
    var usage: Int {
        get {
            let search = NSPredicate(format: "serviceName like %@", argumentArray: [name])
            if let context = AppDelegate.persistantStore?.viewContext {
                let request = NSFetchRequest<ServiceUsage>(entityName: "ServiceUsage")
                request.predicate = search

                return (try? context.fetch(request).count) ?? 0
            }
            return 0
        }

        set {
            if let context = AppDelegate.persistantStore?.viewContext {
                if let object = NSEntityDescription.insertNewObject(forEntityName: "ServiceUsage", into: context) as? ServiceUsage {
                    object.date = Date()
                    object.serviceName = name

                    try? context.save()
                }
            }
        }
    }

    func clearUsage(completion block: (() -> Void)? = nil) {
        let search = NSPredicate(format: "serviceName like %@", argumentArray: [name])
        if let context = AppDelegate.persistantStore?.viewContext {
            let request = NSFetchRequest<ServiceUsage>(entityName: "ServiceUsage")
            request.predicate = search

            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request, completionBlock: { results in
                guard let objects = results.finalResult else {
                    block?()
                    return
                }

                for object in objects {
                    context.delete(object)
                }
                try? context.save()

                block?()
            })

            _ = try? context.execute(asyncRequest)
        }
    }

    var usageToday: Int {
        let calendar = NSCalendar.current
        let endDate = NSDate()
        let startDate = calendar.date(byAdding: .day, value: -1, to: endDate as Date)! as NSDate
        let search = NSPredicate(format: "(date >= %@) AND serviceName like %@", argumentArray: [startDate, name])
        if let context = AppDelegate.persistantStore?.viewContext {
            let request = NSFetchRequest<ServiceUsage>(entityName: "ServiceUsage")
            request.predicate = search
            return (try? context.fetch(request).count) ?? 0
        }
        return 0
    }

    var usageMonth: Int {
        let calendar = NSCalendar.current
        let endDate = NSDate()
        let startDate = calendar.date(byAdding: .month, value: -1, to: endDate as Date)! as NSDate
        let search = NSPredicate(format: "date >= %@ AND serviceName like %@", argumentArray: [startDate, name])
        if let context = AppDelegate.persistantStore?.viewContext {
            let request = NSFetchRequest<ServiceUsage>(entityName: "ServiceUsage")
            request.predicate = search
            return (try? context.fetch(request).count) ?? 0
        }
        return 0
    }

    var usageYear: Int {
        let calendar = NSCalendar.current
        let endDate = NSDate()
        let startDate = calendar.date(byAdding: .year, value: -1, to: endDate as Date)! as NSDate
        let search = NSPredicate(format: "date >= %@ AND serviceName like %@", argumentArray: [startDate, name])
        if let context = AppDelegate.persistantStore?.viewContext {
            let request = NSFetchRequest<ServiceUsage>(entityName: "ServiceUsage")
            request.predicate = search
            return (try? context.fetch(request).count) ?? 0
        }
        return 0
    }
}
