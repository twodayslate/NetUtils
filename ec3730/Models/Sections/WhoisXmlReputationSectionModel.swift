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
    func configure(with record: WhoisXmlReputationRecord) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(record)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let score = record.reputationScore {
            content.append(.row(title: "Score", content: "\(score)"))
        } else {
            content.append(.row(title: "Score", content: "-"))
        }
        content.append(.row(title: "Mode", content: "\(record.mode ?? "-")"))

        guard let tests = record.testResults else {
            return copyData
        }

        for test in tests {
            var rows = [CopyCellType]()
            for warning in test.warnings {
                rows.append(.row(title: "", content: warning, style: .expandable))
            }
            content.append(.multiple(title: test.test, contents: rows))
        }

        return copyData
    }

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let host = url?.host else {
            throw URLError(.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
            throw MoreStoreKitError.NotPurchased
        }

        let response: WhoisXmlReputationRecord = try await WhoisXml.reputationService.query([
            "domain": host,
            "mode": "fast",
            "minimumBalance": 25,
        ])

        return try configure(with: response)
    }
}
