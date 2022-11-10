import Cache
import Foundation

@MainActor
class WhoIsXmlGeoLocationSectionModel: HostSectionModel {
    required convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.GeoLocationService, storeModel: StoreKitModel.geoLocation)
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        reset()

        let result = try JSONDecoder().decode(WhoIsXmlGeoLocationResult.self, from: data)

        return try configure(with: result)
    }

    @MainActor
    func configure(with records: WhoIsXmlGeoLocationResult) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(records)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let ip = records.ip, !ip.isEmpty {
            let row = CopyCellType.row(title: "IP", content: ip)
            content.append(row)
        }
        if let isp = records.isp, !isp.isEmpty {
            let row = CopyCellType.row(title: "Isp", content: isp)
            content.append(row)
        }

        if let domains = records.domains, !domains.isEmpty {
            if domains.count > 1 {
                let row = CopyCellType.multiple(title: "Domains", contents: domains.map { .content($0, style: .expandable) })
                content.append(row)
            } else if domains.count == 1 {
                let row = CopyCellType.row(title: "Domain", content: domains[0])
                content.append(row)
            }
        }

        var locationRows = [CopyCellType]()

        if let country = records.location?.country, !country.isEmpty {
            locationRows.append(.row(title: "Country", content: country, style: .expandable))
        }

        if let region = records.location?.region, !region.isEmpty {
            locationRows.append(.row(title: "Region", content: region, style: .expandable))
        }

        if let city = records.location?.city, !city.isEmpty {
            locationRows.append(.row(title: "City", content: city, style: .expandable))
        }

        if let lat = records.location?.lat {
            locationRows.append(.row(title: "Latitude", content: "\(lat)", style: .expandable))
        }

        if let lng = records.location?.lng {
            locationRows.append(.row(title: "Longitude", content: "\(lng)", style: .expandable))
        }

        if let postalCode = records.location?.postalCode, !postalCode.isEmpty {
            locationRows.append(.row(title: "Postal Code", content: postalCode, style: .expandable))
        }

        if let timezone = records.location?.timezone, !timezone.isEmpty {
            locationRows.append(.row(title: "Timezone", content: timezone, style: .expandable))
        }

        if let geonameId = records.location?.geonameID, geonameId != 0 {
            locationRows.append(.row(title: "GeonameId", content: "\(geonameId)", style: .expandable))
        }

        if !locationRows.isEmpty {
            content.append(.multiple(title: "Location", contents: locationRows))
        }

        if let geoLocationModelClassAs = records.geoLocationModelClassAs {
            var geoLocationAsRows = [CopyCellType]()
            if let asn = geoLocationModelClassAs.asn {
                geoLocationAsRows.append(.row(title: "Asn", content: "\(asn)", style: .expandable))
            }

            if let name = geoLocationModelClassAs.name, !name.isEmpty {
                geoLocationAsRows.append(.row(title: "Name", content: name, style: .expandable))
            }

            if let domain = geoLocationModelClassAs.domain, !domain.isEmpty {
                geoLocationAsRows.append(.row(title: "Domain", content: domain, style: .expandable))
            }

            if let route = geoLocationModelClassAs.route, !route.isEmpty {
                geoLocationAsRows.append(.row(title: "Route", content: "\(route)", style: .expandable))
            }
            if let type = geoLocationModelClassAs.type, !type.isEmpty {
                geoLocationAsRows.append(.row(title: "Type", content: "\(type)", style: .expandable))
            }

            if !geoLocationAsRows.isEmpty {
                content.append(.multiple(title: "GeoLocationAsRows", contents: geoLocationAsRows))
            }
        }

        return copyData
    }

    private let cache = MemoryStorage<String, WhoIsXmlGeoLocationResult>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))

    @discardableResult
    override func query(url: URL? = nil) async throws -> Data {
        reset()

        guard let host = url?.host else {
            throw URLError(.badURL)
        }
        latestQueriedUrl = url
        latestQueryDate = .now

        if let record = try? cache.object(forKey: host) {
            return try configure(with: record)
        }

        guard dataFeed.userKey != nil || storeModel?.owned ?? false else {
            throw MoreStoreKitError.NotPurchased
        }

        let response: WhoIsXmlGeoLocationResult = try await WhoisXml.GeoLocationService.query(
            [
                "domain": host,
                "minimumBalance": 25,
            ]
        )

        cache.setObject(response, forKey: host)

        return try configure(with: response)
    }
}
