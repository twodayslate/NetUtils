import SwiftUI

class GoogleWebRiskSectionModel: HostSectionModel {
    required convenience init() {
        self.init(GoogleWebRisk.current, service: GoogleWebRisk.lookupService)
        storeModel = StoreKitModel.webrisk
    }

    override var demoUrl: URL {
        URL(staticString: "http://testsafebrowsing.appspot.com/malware.html")
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        reset()
        var result = GoogleWebRiskRecordWrapper()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        do {
            result = try decoder.decode(GoogleWebRiskRecordWrapper.self, from: data)
        } catch let decodeError {
            print(decodeError)
        }
        return try configure(with: result)
    }

    @MainActor
    func configure(with record: GoogleWebRiskRecordWrapper) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(record)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let threats = record.threat {
            for threat in threats.threatTypes {
                content.append(.row(title: "Risk", content: threat.description))
            }
        } else {
            content.append(.row(title: "Risk", content: "None detected"))
        }
        return copyData
    }

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let host = url?.absoluteString else {
            throw URLError(.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
            throw MoreStoreKitError.NotPurchased
        }

        let response: GoogleWebRiskRecordWrapper = try await GoogleWebRisk.lookupService.query(["uri": host])

        return try configure(with: response)
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static var iso8601WithFractionalSeconds = custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let formatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd",
            "yyyy-MM-dd HH:mm:ss.SSS ZZZ",
            "yyyy-MM-dd HH:mm:ss ZZZ", // 1997-09-15 07:00:00 UTC
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // 2019-10-17T06:38:04.993563079Z
        ]

        // 2019-10-17T06:38:04.993563079Z
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        let iso = ISO8601DateFormatter()
        iso.timeZone = TimeZone(abbreviation: "UTC")
        if let date = iso.date(from: dateString) {
            return date
        }

        let isoProto = ISO8601DateFormatter()
        isoProto.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoProto.timeZone = TimeZone(secondsFromGMT: 0)!
        if let date = isoProto.date(from: dateString) {
            return date
        }

        if let date = ISO8601DateFormatter().date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(in: container,
                                               debugDescription: "Cannot decode date string \(dateString)")
    }
}
