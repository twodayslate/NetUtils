import SwiftUI
import Cache

class WhoisXmlReputationSectionModel: HostSectionModel {
    convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.reputationService)
        self.storeModel = StoreKitModel.whois
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        self.reset()
        
        let result = try JSONDecoder().decode(WhoisXmlReputationRecord.self, from: data)
        
        return try self.configure(with: result)
    }
    
    @MainActor
    func configure(with record: WhoisXmlReputationRecord) throws -> Data? {
        self.reset()
        
        let copyData = try JSONEncoder().encode(record)
        self.latestData = copyData
        self.dataToCopy = String(data: copyData, encoding: .utf8)
        
        if let score = record.reputationScore {
            self.content.append(CopyCellView(title: "Score", content: "\(score)"))
        } else {
            self.content.append(CopyCellView(title: "Score", content: "-"))
        }
        self.content.append(CopyCellView(title: "Mode", content: "\(record.mode ?? "-")"))
        
        guard let tests = record.testResults else {
            return copyData
        }
        
        for test in tests {
            var rows = [CopyCellRow]()
            for warning in test.warnings {
                rows.append(CopyCellRow(title: "", content: warning))
            }
            self.content.append(CopyCellView(title: test.test, rows: rows))
        }
        
        return copyData
    }
    
    @MainActor
    override func query(url: URL? = nil, completion block: ((Error?, Data?) -> ())? = nil) {
        self.reset()
        
        guard let host = url?.host else {
            block?(URLError(.badURL), nil)
            return
        }
        
        guard (self.dataFeed.userKey != nil || self.storeModel?.owned ?? false) else {
            block?(MoreStoreKitError.NotPurchased, nil)
            return
        }
        
        WhoisXml.reputationService.query(["domain": host, "mode": "fast", "minimumBalance": 50]) { (error, response: WhoisXmlReputationRecord?) in
            print(error ?? "", response ?? "")
            DispatchQueue.main.async {
                guard error == nil else {
                    block?(error, nil)
                    return
                }
                
                guard let response = response else {
                    block?(URLError(URLError.badServerResponse), nil)
                    return
                }
                
                do {
                    block?(nil, try self.configure(with: response))
                } catch {
                    block?(error, nil)
                }
            }
        }
        
//        WhoisXml.dnsService.query(["domain": host]) { (error, response: DnsCoordinate?) in
//            DispatchQueue.main.async {
//                print(response.debugDescription)
//
//                    guard error == nil else {
//                        // todo show error
//                        block?(error, nil)
//                        return
//                    }
//
//                    guard let response = response else {
//                        // todo show error
//                        block?(URLError(URLError.badServerResponse), nil)
//                        return
//                    }
//
//
//                guard let record = response.dnsData.dnsRecords else {
//                    block?(URLError(URLError.badServerResponse), nil)
//                    return
//                }
//                self.cache.setObject(record, forKey: host)
//                do {
//                    block?(nil, try self.configure(with: record))
//                } catch {
//                    block?(error, nil)
//                }
//            }
//        }
    }
}

