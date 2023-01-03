import Cache
import Foundation

@MainActor
class WhoIsXmlCategorizationSectionModel: HostSectionModel {
    required convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.CategorizationService, storeModel: StoreKitModel.categorization)
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        reset()

        let result = try JSONDecoder().decode(WhoIsXmlCategorizationResult.self, from: data)

        return try configure(with: result)
    }

    @MainActor
    func configure(with records: WhoIsXmlCategorizationResult) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(records)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let categories = records.categories {
            for (index, category) in categories.enumerated() {
                var rows = [CopyCellType]()

                if let tier1 = category.tier1 {
                    let name = tier1.name ?? ""
                    let confidence = tier1.confidence ?? 0.0
                    let id = tier1.id ?? ""

                    rows.append(.row(title: "Tier1", content: "Name - \(name)\n Id - \(id)\n Confidence - \(confidence)", style: .expandable))
                }

                if let tier2 = category.tier2 {
                    let name = tier2.name ?? ""
                    let confidence = tier2.confidence ?? 0.0
                    let id = tier2.id ?? ""
                    rows.append(.row(title: "Tier2", content: "Name - \(name)\n Id - \(id)\n Confidence - \(confidence)", style: .expandable))
                }

                if !rows.isEmpty {
                    content.append(.multiple(title: "Category \(index + 1)", contents: rows))
                }
            }
        }

        return copyData
    }

    private let cache = MemoryStorage<String, WhoIsXmlCategorizationResult>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let host = url?.host else {
            throw URLError(.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        if let record = try? cache.object(forKey: host) {
            return try configure(with: record)
        }

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
            throw MoreStoreKitError.NotPurchased
        }

        let response: WhoIsXmlCategorizationResult = try await WhoisXml.CategorizationService.query(
            [
                "domain": host,
                "minimumBalance": 25,
            ]
        )

        cache.setObject(response, forKey: host)

        return try configure(with: response)
    }
}
