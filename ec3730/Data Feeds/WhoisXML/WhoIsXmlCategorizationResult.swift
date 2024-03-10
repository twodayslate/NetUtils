import Foundation

// MARK: - ActivityModelClass

struct WhoIsXmlCategorizationResultV3: Codable {
    let categories: [TierV3]?
    let domainName: String?
    let websiteResponded: Bool?
    let autonomousSystem: CategorizationAutonomousSystem?

    enum CodingKeys: String, CodingKey {
        case categories
        case domainName
        case websiteResponded
        case autonomousSystem = "as"
    }
}

/// Autonomous System (AS)
struct CategorizationAutonomousSystem: Codable {
    let asn: Int?
    let domain: String?
    let name: String?
    let route: String?
    let type: String?
}

struct WhoIsXmlCategorizationResultV2: Codable {
    let categories: [CategoryResult]?
    let domainName: String?
    let websiteResponded: Bool?
}

extension WhoIsXmlCategorizationResultV2 {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Self.self, from: data)
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
              websiteResponded: Bool? = nil) -> Self {
        Self(categories: categories ?? self.categories,
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
    let tier1: TierV2?
    let tier2: TierV2?
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

    func with(tier1: TierV2? = nil,
              tier2: TierV2? = nil) -> CategoryResult {
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

struct TierV2: Codable {
    let confidence: Double?
    let id, name: String?
}

struct TierV3: Codable {
    let confidence: Double?
    let id: Int?
    let name: String?
}
