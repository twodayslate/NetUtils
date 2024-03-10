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

        do {
            let result = try JSONDecoder().decode(WhoIsXmlCategorizationResultV3.self, from: data)
            if shouldCheckV2(result) {
                let result = try JSONDecoder().decode(WhoIsXmlCategorizationResultV2.self, from: data)
                return try configure(with: result)
            }
            return try configure(with: result)
        } catch {
            let result = try JSONDecoder().decode(WhoIsXmlCategorizationResultV2.self, from: data)
            return try configure(with: result)
        }
    }

    // we heavily use optional to avoid bad parsing since stuff from whosixml isn't consistent so we check somethings that will be optional on v3 that v2 doesn't have
    func shouldCheckV2(_ value: WhoIsXmlCategorizationResultV3) -> Bool {
        value.autonomousSystem?.asn == nil && value.categories?.first?.name == nil
    }

    @MainActor
    func configure(with records: WhoIsXmlCategorizationResultV3) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(records)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let categories = records.categories {
            for category in categories {
                var rows = [CopyCellType]()
                if let id = category.id {
                    rows.append(.row(title: "ID", content: "\(id)", style: .expandable))
                }
                if let confidence = category.confidence {
                    rows.append(.row(title: "Confidence", content: "\(confidence)", style: .expandable))
                }

                if let name = category.name, !rows.isEmpty {
                    content.append(.multiple(title: name, contents: rows))
                }
            }
        }

        if let autonomousSystem = records.autonomousSystem {
            var rows = [CopyCellType]()

            if let asn = autonomousSystem.asn {
                rows.append(.row(title: "ASN", content: "\(asn)", style: .expandable))
            }
            if let asn = autonomousSystem.domain {
                rows.append(.row(title: "Domain", content: "\(asn)", style: .expandable))
            }
            if let asn = autonomousSystem.name {
                rows.append(.row(title: "Name", content: "\(asn)", style: .expandable))
            }
            if let asn = autonomousSystem.route {
                rows.append(.row(title: "Route", content: "\(asn)", style: .expandable))
            }
            if let asn = autonomousSystem.type {
                rows.append(.row(title: "Type", content: "\(asn)", style: .expandable))
            }

            if !rows.isEmpty {
                content.append(.multiple(title: "Autonomous System (AS)", contents: rows))
            }
        }

        return copyData
    }

    @MainActor
    func configure(with records: WhoIsXmlCategorizationResultV2) throws -> Data {
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

    private let cache = MemoryStorage<String, WhoIsXmlCategorizationResultV3>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let host = url?.host else {
            throw URLError(.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        if let record = try? cache.object(forKey: host + "v3") {
            return try configure(with: record)
        }

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
            throw MoreStoreKitError.NotPurchased
        }

        let response: WhoIsXmlCategorizationResultV3 = try await WhoisXml.CategorizationService.query(
            [
                "url": url,
                "minimumBalance": 25,
            ]
        )

        cache.setObject(response, forKey: host)

        return try configure(with: response)
    }
}
