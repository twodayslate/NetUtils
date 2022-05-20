import Cache
import SwiftUI

class WhoisXmlDnsSectionModel: HostSectionModel {
    convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.dnsService)
        storeModel = StoreKitModel.dns
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        reset()

        let result = try JSONDecoder().decode([DNSRecords].self, from: data)

        return try configure(with: result)
    }

    @MainActor
    func configure(with records: [DNSRecords]) throws -> Data? {
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

        return latestData
    }

    private let cache = MemoryStorage<String, [DNSRecords]>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))

    @MainActor
    override func query(url: URL? = nil, completion block: ((Error?, Data?) -> Void)? = nil) {
        reset()

        guard let host = url?.host else {
            block?(URLError(.badURL), nil)
            return
        }

        if let record = try? cache.object(forKey: host) {
            do {
                block?(nil, try configure(with: record))
            } catch {
                block?(error, nil)
            }
            return
        }

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
            block?(MoreStoreKitError.NotPurchased, nil)
            return
        }

        WhoisXml.dnsService.query(["domain": host]) { (error, response: DnsCoordinate?) in
            DispatchQueue.main.async {
                print(response.debugDescription)

                guard error == nil else {
                    // todo show error
                    block?(error, nil)
                    return
                }

                guard let response = response else {
                    // todo show error
                    block?(URLError(URLError.badServerResponse), nil)
                    return
                }

                guard let record = response.dnsData.dnsRecords else {
                    block?(URLError(URLError.badServerResponse), nil)
                    return
                }
                self.cache.setObject(record, forKey: host)
                do {
                    block?(nil, try self.configure(with: record))
                } catch {
                    block?(error, nil)
                }
            }
        }
    }
}
