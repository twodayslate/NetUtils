import SwiftUI

class LocalDnsModel: HostSectionModel {
    convenience init() {
        self.init(LocalDns.current, service: LocalDns.lookupService)
    }

    @MainActor
    override func configure(with data: Data?) throws -> Data? {
        reset()

        guard let data = data else {
            return nil
        }

        let addresses = try JSONDecoder().decode([String].self, from: data)

        return try configure(addresses: addresses)
    }

    @MainActor
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

    @MainActor
    override func query(url: URL? = nil, completion block: ((Error?, Data?) -> Void)? = nil) {
        // we are already on the main queue
        reset()

        guard let host = url?.host else {
            block?(URLError(URLError.badURL), nil)
            return
        }

        service.query(["host": host]) { (responseError, response: [String]?) in
            DispatchQueue.main.async {
                guard responseError == nil else {
                    block?(responseError, nil)
                    return
                }

                guard let addresses = response else {
                    block?(URLError(URLError.badServerResponse), nil)
                    return
                }

                do {
                    block?(nil, try self.configure(addresses: addresses))
                } catch {
                    block?(error, nil)
                }
            }
        }
    }
}
