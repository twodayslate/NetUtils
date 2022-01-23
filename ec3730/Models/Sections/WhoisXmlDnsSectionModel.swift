import SwiftUI
import Cache

class WhoisXmlDnsSectionModel: HostSectionModel {
    convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.dnsService)
        self.storeModel = StoreKitModel.dns
    }

    override func configure(with data: Data) {
        self.content.removeAll()
        self.dataToCopy = nil
        guard let result = try? JSONDecoder().decode([DNSRecords].self, from: data) else {
            return
        }
        self.configure(with: result)
    }
    
    func configure(with records: [DNSRecords]) {
        DispatchQueue.main.async {
            self.content.removeAll()
            
            if let copyData = try? JSONEncoder().encode(records) {
                self.dataToCopy = String(data: copyData, encoding: .utf8)
            }
            
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

                self.content.append(CopyCellView(title: record.dnsType, rows: rows))
            }
        }
    }
    
    private let cache = MemoryStorage<String, [DNSRecords]>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))
    
    override func query(url: URL? = nil, completion block: (() -> ())? = nil) {
        self.dataToCopy = nil
        self.content.removeAll()
        
        guard let host = url?.host else {
            block?()
            return
        }
        
        if let record = try? cache.object(forKey: host) {
            self.configure(with: record)
            block?()
            return
        }
        
        guard (self.dataFeed.userKey != nil || self.storeModel?.owned ?? false) else {
            block?()
            return
        }
        
        WhoisXml.dnsService.query(["domain": host]) { (error, response: DnsCoordinate?) in
            print(response.debugDescription)

                defer {
                    block?()
                }
                
                guard error == nil else {
                    // todo show error
                    return
                }

                guard let response = response else {
                    // todo show error
                    return
                }

            
            guard let record = response.dnsData.dnsRecords else {
                return
            }
            self.cache.setObject(record, forKey: host)
            self.configure(with: record)
        }
    }
}

