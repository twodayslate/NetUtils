import Foundation

// MARK: - WhoIsXmlGeoLocationResult

struct WhoIsXmlGeoLocationResult: Codable {
    let ip: String?
    let location: Location?
    let domains: [String]?
    let geoLocationModelClassAs: GeoLocationAs?
    let isp, connectionType: String?

    enum CodingKeys: String, CodingKey {
        case ip, location, domains
        case geoLocationModelClassAs = "as"
        case isp, connectionType
    }
}

extension WhoIsXmlGeoLocationResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WhoIsXmlGeoLocationResult.self, from: data)
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

    func with(ip: String? = nil,
              location: Location? = nil,
              domains: [String]? = nil,
              geoLocationModelClassAs: GeoLocationAs? = nil,
              isp: String? = nil,
              connectionType: String? = nil) -> WhoIsXmlGeoLocationResult {
        WhoIsXmlGeoLocationResult(ip: ip ?? self.ip, location: location ?? self.location, domains: domains ?? self.domains, geoLocationModelClassAs: geoLocationModelClassAs ?? self.geoLocationModelClassAs, isp: isp ?? self.isp, connectionType: connectionType ?? self.connectionType)
    }

    func jsonData() throws -> Data {
        try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        String(data: try jsonData(), encoding: encoding)
    }
}

// MARK: - GeoLocationAs

struct GeoLocationAs: Codable {
    let asn: Int?
    let name, route: String?
    let domain: String?
    let type: String?
}

// MARK: - Location

struct Location: Codable {
    let country, region, city: String?
    let lat, lng: Double?
    let postalCode, timezone: String?
    let geonameID: Int?

    enum CodingKeys: String, CodingKey {
        case country, region, city, lat, lng, postalCode, timezone
        case geonameID = "geonameId"
    }
}
