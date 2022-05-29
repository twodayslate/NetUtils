import Cache
import SwiftUI

class WhoisXmlReputationSectionModel: HostSectionModel {
    required convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.reputationService)
        storeModel = StoreKitModel.whois
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        reset()

        let result = try JSONDecoder().decode(WhoisXmlReputationRecord.self, from: data)

        return try configure(with: result)
    }

    @MainActor
    func configure(with record: WhoisXmlReputationRecord) throws -> Data? {
        reset()

        let copyData = try JSONEncoder().encode(record)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let score = record.reputationScore {
            content.append(CopyCellView(title: "Score", content: "\(score)"))
        } else {
            content.append(CopyCellView(title: "Score", content: "-"))
        }
        content.append(CopyCellView(title: "Mode", content: "\(record.mode ?? "-")"))

        guard let tests = record.testResults else {
            return copyData
        }

        for test in tests {
            var rows = [CopyCellRow]()
            for warning in test.warnings {
                rows.append(CopyCellRow(title: "", content: warning))
            }
            content.append(CopyCellView(title: test.test, rows: rows))
        }

        return copyData
    }

    @MainActor
    override func query(url: URL? = nil, completion block: ((Error?, Data?) -> Void)? = nil) {
        reset()

        guard let host = url?.host else {
            block?(URLError(.badURL), nil)
            return
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
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
    }
}
