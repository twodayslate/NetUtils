import Cache
import SwiftUI

@MainActor
class WhoisXmlDnsSectionModel: HostSectionModel {
    required convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.dnsService, storeModel: StoreKitModel.dns)
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        reset()

        let result = try JSONDecoder().decode([DNSRecords].self, from: data)

        return try configure(with: result)
    }

    @MainActor
    func configure(with records: [DNSRecords]) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(records)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        for record in records {
            var rows = [CopyCellType]()

            rows.append(.row(title: "name", content: record.name, style: .expandable))
            rows.append(.row(title: "ttl", content: "\(record.ttl)", style: .expandable))
            rows.append(.row(title: "RRset Type", content: "\(record.rRsetType)", style: .expandable))

            if let admin = record.admin {
                rows.append(.row(title: "Admin", content: admin, style: .expandable))
            }
            if let host = record.host {
                rows.append(.row(title: "Host", content: host, style: .expandable))
            }
            if let address = record.address {
                rows.append(.row(title: "Address", content: address, style: .expandable))
            }
            if let strings = record.strings {
                let row = CopyCellType.row(title: "Strings", content: strings.joined(separator: "\n"), style: .expandable)
                rows.append(row)
            }
            if let expire = record.expire {
                rows.append(.row(title: "Expire", content: "\(expire)", style: .expandable))
            }
            if let value = record.minimum {
                rows.append(.row(title: "Minimum", content: "\(value)", style: .expandable))
            }
            if let value = record.refresh {
                rows.append(.row(title: "Refresh", content: "\(value)", style: .expandable))
            }
            if let value = record.retry {
                rows.append(.row(title: "Retry", content: "\(value)", style: .expandable))
            }
            if let value = record.serial {
                rows.append(.row(title: "Serial", content: "\(value)", style: .expandable))
            }

            rows.append(.row(title: "Raw", content: record.rawText, style: .expandable))

            content.append(.multiple(title: record.dnsType, contents: rows))
        }

        return copyData
    }

    private let cache = MemoryStorage<String, [DNSRecords]>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))

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

        let response: DnsCoordinate = try await WhoisXml.dnsService.query(["domain": host])

        guard let record = response.dnsData.dnsRecords else {
            throw URLError(URLError.badServerResponse)
        }
        cache.setObject(record, forKey: host)

        return try configure(with: record)
    }
}
