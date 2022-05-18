import Foundation
import SwiftUI
import Combine


@available(iOS 15.0, *)
class HostSectionModel: ObservableObject, Equatable, Identifiable, Hashable {
    
    @MainActor
    @Published var content = [CopyCellView]()

    @Published var isVisible = false
    
    var section: HostViewSection? = nil
    
    var dataFeed: DataFeed
    var service: Service
    
    var dataToCopy: String? = nil
    var latestData: Data? = nil
        
    @Published var storeModel: StoreKitModel?
    
    init(_ feed: DataFeed, service: Service) {
        self.dataFeed = feed
        self.service = service
    }
    
    @MainActor
    class func configure(with result: HostData) -> HostSectionModel? {
        let available_services = [
            LocalDnsModel(),
            WhoisXmlWhoisSectionModel(),
            GoogleWebRiskSectionModel(),
            WhoisXmlReputationSectionModel(),
            WhoisXmlDnsSectionModel()
        ]
        
        for service in available_services {
            if result.service == service.service.name {
                
                do {
                    let _ = try service.configure(with: result.data)
                    return service
                }
                catch {}
            }
        }
        
        return nil
    }
    
    @MainActor
    func configure(with data: Data) throws -> Data? {
        fatalError("Configure your section configure data function")
    }
    
    // completion block has an error and or data
    @MainActor
    func query(url: URL? = nil, completion block: ((Error?, Data?)->())? = nil) {
        fatalError("Configure your section query")
    }
    
    static func == (lhs: HostSectionModel, rhs: HostSectionModel) -> Bool {
        return lhs.service.name == rhs.service.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.service.name)
    }
    
    // this must be called in the main queue
    @MainActor
    internal func reset() {
        self.dataToCopy = nil
        self.content.removeAll()
        self.latestData = nil
    }
}
