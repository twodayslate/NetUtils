import SwiftUI

@MainActor
class UrlParsedModel: HostSectionModel {
    required convenience init() {
        self.init(URLParsedFeed.current, service: URLParsedFeed.lookupService)
    }

    override func configure(with data: Data?) throws -> Data? {
        reset()

        guard let data = data else {
            return nil
        }

        let url = try JSONDecoder().decode(URL.self, from: data)

        return try configure(url: url)
    }

    func configure(url: URL) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(url)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let host = url.host {
            content.append(.row(title: "Host", content: host))
        }
        if let port = url.port {
            content.append(.row(title: "Port", content: "\(port)"))
        }
        if let scheme = url.scheme {
            content.append(.row(title: "Scheme", content: scheme))
        }
        if let fragment = url.fragment {
            content.append(.row(title: "Fragment", content: fragment))
        }
        if let user = url.user {
            content.append(.row(title: "User", content: user))
        }
        if let password = url.password {
            content.append(.row(title: "Password", content: password))
        }
        content.append(.row(title: "Path", content: url.path))
        if !url.pathComponents.isEmpty {
            content.append(.multiple(title: "Path Components", contents: url.pathComponents.map { .content($0, style: .gray) }))
        }
        content.append(.row(title: "Path Extension", content: url.pathExtension))
        content.append(.row(title: "Last Path Component", content: url.lastPathComponent))
        if let query = url.query {
            content.append(.row(title: "Query", content: query))
        }
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let queryItems = components.queryItems {
                var items = [CopyCellType]()
                for item in queryItems {
                    items.append(.row(title: item.name, content: item.value ?? ""))
                }
                content.append(.multiple(title: "Query Items", contents: items))
            }
        }

        return copyData
    }

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let url else {
            throw URLError(URLError.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        return try configure(url: url)
    }
}
