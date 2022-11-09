import Foundation

// MARK: - ActivityModelClass

struct WhoIsXmlCategorizationResult: Codable {
    let categories: [CategoryResult]?
    let domainName: String?
    let websiteResponded: Bool?
}

extension WhoIsXmlCategorizationResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoIsXmlCategorizationResult.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(categories: [CategoryResult]? = nil,
              domainName: String? = nil,
              websiteResponded: Bool? = nil) -> WhoIsXmlCategorizationResult {
        WhoIsXmlCategorizationResult(categories: categories ?? self.categories,
                                     domainName: domainName ?? self.domainName,
                                     websiteResponded: websiteResponded ?? self.websiteResponded)
    }

    func jsonData() throws -> Data {
        try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        String(data: try jsonData(), encoding: encoding)
    }
}

// MARK: - CategoryResult

struct CategoryResult: Codable {
    let tier1: Tier?
    let tier2: Tier?
}

extension CategoryResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CategoryResult.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(tier1: Tier? = nil,
              tier2: Tier? = nil) -> CategoryResult {
        CategoryResult(tier1: tier1 ?? self.tier1, tier2: tier2 ?? self.tier2)
    }

    func jsonData() throws -> Data {
        try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        String(data: try jsonData(), encoding: encoding)
    }
}

// MARK: - Tier

struct Tier: Codable {
    let confidence: Double?
    let id, name: String?
}
