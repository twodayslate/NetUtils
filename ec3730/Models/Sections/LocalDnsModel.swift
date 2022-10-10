import SwiftUI

@MainActor
class LocalDnsModel: HostSectionModel {
    required convenience init() {
        self.init(LocalDns.current, service: LocalDns.lookupService)
    }

    override func configure(with data: Data?) throws -> Data? {
        reset()

        guard let data = data else {
            return nil
        }

        let addresses = try JSONDecoder().decode([String].self, from: data)

        return try configure(addresses: addresses)
    }

    func configure(addresses: [String]) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(addresses)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        for address in addresses {
            content.append(CopyCellView(title: "Address", content: address))
        }

        return copyData
    }

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let host = url?.host else {
            throw URLError(URLError.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        let addresses: [String] = try await service.query(["host": host])

        return try configure(addresses: addresses)
    }
}
