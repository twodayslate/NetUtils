import Foundation
import SwiftUI
import Combine


@available(iOS 15.0, *)
class HostSectionModel: ObservableObject, Equatable, Identifiable, Hashable {
    
    @Published var content = [CopyCellView]()

    @Published var isVisible = false
    
    var section: HostViewSection? = nil
    
    var dataFeed: DataFeed
    var service: Service
    
    var dataToCopy: String? = nil
    
    @Published var storeModel: StoreKitModel?
    
    init(_ feed: DataFeed, service: Service) {
        self.dataFeed = feed
        self.service = service
    }
    
    class func configure(with result: HostData) -> HostSectionModel? {
        let available_services = [
            LocalDnsModel(),
            WhoisXmlWhoisSectionModel(),
            GoogleWebRiskSectionModel(),
            WhoisXmlDnsSectionModel()
        ]
        
        for service in available_services {
            if result.service == service.service.name {
                
                service.configure(with: result.data)
                return service
                
            }
        }
        
        return nil
    }
    
    func configure(with data: Data) {
        fatalError("Configure your section configure data function")
    }
    
    func query(url: URL? = nil, completion block: (()->())? = nil) {
        fatalError("Configure your section query")
    }
    
    static func == (lhs: HostSectionModel, rhs: HostSectionModel) -> Bool {
        return lhs.service.name == rhs.service.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.service.name)
    }
}
