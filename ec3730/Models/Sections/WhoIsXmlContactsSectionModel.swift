import Cache
import Foundation
import SwiftUI

@MainActor
class WhoIsXmlContactsSectionModel: HostSectionModel {
    required convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.contactsService, storeModel: StoreKitModel.contacts)
    }

    @MainActor
    override func configure(with data: Data) throws -> Data? {
        reset()

        let result = try JSONDecoder().decode(WhoIsXmlContactsResult.self, from: data)

        return try configure(with: result)
    }

    @MainActor
    func configure(with records: WhoIsXmlContactsResult) throws -> Data {
        reset()

        let copyData = try JSONEncoder().encode(records)
        latestData = copyData
        dataToCopy = String(data: copyData, encoding: .utf8)

        if let names = records.companyNames, !names.isEmpty {
            if names.count > 1 {
                let row = CopyCellView(title: "Company Names", rows: names.map { CopyCellRow(content: $0) })
                content.append(row)
            } else {
                let row = CopyCellView(title: "Company Names", content: names[0])
                content.append(row)
            }
        }

        content.append(CopyCellView(title: "Title", content: records.meta?.title))

        content.append(CopyCellView(title: "Description", content: records.meta?.metaDescription))

        if let postal = records.postalAddresses {
            let row = CopyCellView(title: "Postal Addresses", content: postal.joined(separator: "\n"))
            content.append(row)
        }

        content.append(CopyCellView(title: "Country code", content: records.countryCode))

        if let emails = records.emails {
            var emailsArr = [String]()
            for email in emails {
                emailsArr.append(email.email ?? "")
            }

            let row = CopyCellView(title: "Emails", content: emailsArr.joined(separator: "\n"))
            content.append(row)
        }

        if let phones = records.phones {
            var phoneArr = [String]()
            for phone in phones {
                let str = "\(phone.phoneNumber ?? "") \(phone.callHours ?? "")"
                phoneArr.append(str)
            }

            let row = CopyCellView(title: "Phone", content: phoneArr.joined(separator: "\n"))
            content.append(row)
        }

        content.append(CopyCellView(title: "Domain name", content: records.domainName))

        content.append(CopyCellView(title: "Website responed", content: "\(records.websiteResponded ?? false)"))

        var socialRows = [CopyCellRow]()

        if let facebook = records.socialLinks?.facebook, !facebook.isEmpty {
            socialRows.append(CopyCellRow(title: "Facebook", content: facebook))
        }

        if let twitter = records.socialLinks?.twitter, !twitter.isEmpty {
            socialRows.append(CopyCellRow(title: "Twitter", content: twitter))
        }

        if let instagram = records.socialLinks?.instagram, !instagram.isEmpty {
            socialRows.append(CopyCellRow(title: "Instagram", content: instagram))
        }

        if let linkedIn = records.socialLinks?.linkedIn, !linkedIn.isEmpty {
            socialRows.append(CopyCellRow(title: "LinkedIn", content: linkedIn))
        }

        if !socialRows.isEmpty {
            content.append(CopyCellView(title: "Social Links", rows: socialRows))
        }

        return copyData
    }

    private let cache = MemoryStorage<String, WhoIsXmlContactsResult>(config: .init(expiry: .seconds(15), countLimit: 3, totalCostLimit: 0))

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

        let response: WhoIsXmlContactsResult = try await WhoisXml.contactsService.query(["domain": host])

        cache.setObject(response, forKey: host)

        return try configure(with: response)
    }
}
