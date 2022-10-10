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
            var rows = [CopyCellRow]()

            rows.append(CopyCellRow(title: "name", content: record.name))
            rows.append(CopyCellRow(title: "ttl", content: "\(record.ttl)"))
            rows.append(CopyCellRow(title: "RRset Type", content: "\(record.rRsetType)"))

            if let admin = record.admin {
                rows.append(CopyCellRow(title: "Admin", content: admin))
            }
            if let host = record.host {
                rows.append(CopyCellRow(title: "Host", content: host))
            }
            if let address = record.address {
                rows.append(CopyCellRow(title: "Address", content: address))
            }
            if let strings = record.strings {
                let row = CopyCellRow(title: "Strings", content: strings.joined(separator: "\n"))
                rows.append(row)
            }
            if let expire = record.expire {
                rows.append(CopyCellRow(title: "Expire", content: "\(expire)"))
            }
            if let value = record.minimum {
                rows.append(CopyCellRow(title: "Minimum", content: "\(value)"))
            }
            if let value = record.refresh {
                rows.append(CopyCellRow(title: "Refresh", content: "\(value)"))
            }
            if let value = record.retry {
                rows.append(CopyCellRow(title: "Retry", content: "\(value)"))
            }
            if let value = record.serial {
                rows.append(CopyCellRow(title: "Serial", content: "\(value)"))
            }

            rows.append(CopyCellRow(title: "Raw", content: record.rawText))

            content.append(CopyCellView(title: record.dnsType, rows: rows))
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
