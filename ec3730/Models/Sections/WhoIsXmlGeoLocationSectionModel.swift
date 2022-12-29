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
            let row = CopyCellView<Any>(title: "IP", content: ip)
            content.append(row)
        }
        if let isp = records.isp, !isp.isEmpty {
            let row = CopyCellView<Any>(title: "Isp", content: isp)
            content.append(row)
        }

        if let domains = records.domains, !domains.isEmpty {
            if domains.count > 1 {
                let row = CopyCellView<Any>(title: "Domains", rows: domains.map { CopyCellRow(content: $0) })
                content.append(row)
            } else if domains.count == 1 {
                let row = CopyCellView<Any>(title: "Domain", content: domains[0])
                content.append(row)
            }
        }

        var locationRows = [CopyCellRow]()

        if let country = records.location?.country, !country.isEmpty {
            locationRows.append(CopyCellRow(title: "Country", content: country))
        }

        if let region = records.location?.region, !region.isEmpty {
            locationRows.append(CopyCellRow(title: "Region", content: region))
        }

        if let city = records.location?.city, !city.isEmpty {
            locationRows.append(CopyCellRow(title: "City", content: city))
        }

        if let lat = records.location?.lat {
            locationRows.append(CopyCellRow(title: "Latitude", content: "\(lat)"))
        }

        if let lng = records.location?.lng {
            locationRows.append(CopyCellRow(title: "Longitude", content: "\(lng)"))
        }

        if let postalCode = records.location?.postalCode, !postalCode.isEmpty {
            locationRows.append(CopyCellRow(title: "Postal Code", content: postalCode))
        }

        if let timezone = records.location?.timezone, !timezone.isEmpty {
            locationRows.append(CopyCellRow(title: "Timezone", content: timezone))
        }

        if let geonameId = records.location?.geonameID, geonameId != 0 {
            locationRows.append(CopyCellRow(title: "GeonameId", content: "\(geonameId)"))
        }

        if !locationRows.isEmpty {
            content.append(CopyCellView(title: "Location", rows: locationRows))
        }

        if let geoLocationModelClassAs = records.geoLocationModelClassAs {
            var geoLocationAsRows = [CopyCellRow]()
            if let asn = geoLocationModelClassAs.asn {
                geoLocationAsRows.append(CopyCellRow(title: "Asn", content: "\(asn)"))
            }

            if let name = geoLocationModelClassAs.name, !name.isEmpty {
                geoLocationAsRows.append(CopyCellRow(title: "Name", content: name))
            }

            if let domain = geoLocationModelClassAs.domain, !domain.isEmpty {
                geoLocationAsRows.append(CopyCellRow(title: "Domain", content: domain))
            }

            if let route = geoLocationModelClassAs.route, !route.isEmpty {
                geoLocationAsRows.append(CopyCellRow(title: "Route", content: "\(route)"))
            }
            if let type = geoLocationModelClassAs.type, !type.isEmpty {
                geoLocationAsRows.append(CopyCellRow(title: "Type", content: "\(type)"))
            }

            if !geoLocationAsRows.isEmpty {
                content.append(CopyCellView(title: "GeoLocationAsRows", rows: geoLocationAsRows))
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
