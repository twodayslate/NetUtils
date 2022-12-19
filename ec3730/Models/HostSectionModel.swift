import Combine
import Foundation
import SwiftUI

@available(iOS 15.0, *)
class HostSectionModel: ObservableObject, Equatable, Identifiable, Hashable {
    @MainActor
    @Published var content = [CopyCellView]()

    @MainActor
    @Published var isVisible = false

    var section: HostViewSection?

    let dataFeed: DataFeed
    let service: Service

    @MainActor @Published
    var dataToCopy: String?
    @MainActor @Published
    var latestData: Data?
    /// The last URL queried
    @MainActor @Published
    var latestQueriedUrl: URL?
    /// The last time data was queried
    @MainActor @Published
    var latestQueryDate: Date?

    @Published var storeModel: StoreKitModel?

    init(_ feed: DataFeed, service: Service, storeModel: StoreKitModel? = nil) {
        dataFeed = feed
        self.service = service
        self.storeModel = storeModel
    }

    required init() {
        fatalError("Configure your model's init function")
    }

    @MainActor
    var demoModel: Self {
        let model = type(of: self).init()
        _ = try? model.initDemoData()
        return model
    }

    var demoDate: Date = .init(timeIntervalSince1970: 1_653_861_813)
    var demoUrl: URL {
        URL(staticString: "https://google.com")
    }

    @MainActor
    func initDemoData() throws -> Data? {
        reset()
        guard let data = loadJson(filename: String(describing: type(of: self))) else {
            return nil
        }
        return try configure(with: data)
    }

    @MainActor
    class func configure(with result: HostData, group: HostDataGroup) -> HostSectionModel? {
        let available_services = [
            LocalDnsModel(),
            WhoisXmlWhoisSectionModel(),
            WhoisXmlDnsSectionModel(),
            WhoisXmlReputationSectionModel(),
            WhoIsXmlContactsSectionModel(),
            WhoIsXmlGeoLocationSectionModel(),
            WhoIsXmlCategorizationSectionModel(),
            GoogleWebRiskSectionModel(),
        ]

        for service in available_services {
            if result.service == service.service.name {
                do {
                    _ = try service.configure(with: result.data)
                    service.latestQueriedUrl = group.url
                    service.latestQueryDate = group.date
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

    @MainActor
    @discardableResult
    func query(url _: URL? = nil) async throws -> Data {
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
