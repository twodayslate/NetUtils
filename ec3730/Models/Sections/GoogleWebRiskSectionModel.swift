import SwiftUI

import SwiftUI

import SwiftUI

class GoogleWebRiskSectionModel: HostSectionModel {
    required convenience init() {
        self.init(GoogleWebRisk.current, service: GoogleWebRisk.lookupService)
        storeModel = StoreKitModel.webrisk
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
                content.append(CopyCellView(title: "Risk", content: threat.description))
            }
        } else {
            content.append(CopyCellView(title: "Risk", content: "None detected"))
        }
        return copyData
    }

    @MainActor
    override func query(url: URL? = nil, completion block: ((Error?, Data?) -> Void)? = nil) {
        reset()

        guard let host = url?.absoluteString else {
            block?(URLError(.badURL), nil)
            return
        }

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
            block?(MoreStoreKitError.NotPurchased, nil)
            return
        }

        GoogleWebRisk.lookupService.query(["uri": host]) { (responseError, response: GoogleWebRiskRecordWrapper?) in
            DispatchQueue.main.async {
                print(response.debugDescription)

                guard responseError == nil else {
                    // todo show error
                    block?(responseError, nil)
                    return
                }

                guard let response = response else {
                    // todo show error
                    block?(URLError(.badServerResponse), nil)
                    return
                }

                do {
                    try block?(nil, self.configure(with: response))
                } catch {
                    block?(error, nil)
                }
            }
        }
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
