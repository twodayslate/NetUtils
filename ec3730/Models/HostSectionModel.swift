import Combine
import Foundation
import SwiftUI

@available(iOS 15.0, *)
class HostSectionModel: ObservableObject, Equatable, Identifiable, Hashable {
    @MainActor
    @Published var content = [CopyCellView]()

    @Published var isVisible = false

    var section: HostViewSection?

    var dataFeed: DataFeed
    var service: Service

    var dataToCopy: String?
    var latestData: Data?

    @Published var storeModel: StoreKitModel?

    init(_ feed: DataFeed, service: Service) {
        dataFeed = feed
        self.service = service
    }

    @MainActor
    func initDemoData() throws -> Data? {
        nil
    }

    @MainActor
    class func configure(with result: HostData) -> HostSectionModel? {
        let available_services = [
            LocalDnsModel(),
            WhoisXmlWhoisSectionModel(),
            GoogleWebRiskSectionModel(),
            WhoisXmlReputationSectionModel(),
            WhoisXmlDnsSectionModel(),
        ]

        for service in available_services {
            if result.service == service.service.name {
                do {
                    _ = try service.configure(with: result.data)
                    return service
                } catch {}
            }
        }

        return nil
    }

    @MainActor
    func configure(with _: Data) throws -> Data? {
        fatalError("Configure your section configure data function")
    }

    // completion block has an error and or data
    @MainActor
    func query(url _: URL? = nil, completion _: ((Error?, Data?) -> Void)? = nil) {
        fatalError("Configure your section query")
    }

    static func == (lhs: HostSectionModel, rhs: HostSectionModel) -> Bool {
        lhs.service.name == rhs.service.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(service.name)
    }

    // this must be called in the main queue
    @MainActor
    internal func reset() {
        dataToCopy = nil
        content.removeAll()
        latestData = nil
    }
}
