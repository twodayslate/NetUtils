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
                let row = CopyCellType.multiple(title: "Company Names", contents: names.compactMap { .content($0, style: .expandable) })
                content.append(row)
            } else if names.count == 1 {
                let row = CopyCellType.row(title: "Company Name", content: names[0])
                content.append(row)
            }
        }

        if let title = records.meta?.title {
            content.append(.row(title: "Title", content: title))
        }

        if let value = records.meta?.metaDescription, !value.isEmpty {
            content.append(.row(title: "Description", content: value))
        }

        if let postal = records.postalAddresses {
            if postal.count > 1 {
                let row = CopyCellType.multiple(title: "Postal Addresses", contents: postal.map { .content($0, style: .expandable) })
                content.append(row)
            } else if postal.count == 1 {
                let row = CopyCellType.row(title: "Postal Address", content: postal[0])
                content.append(row)
            }
        }

        if let countryCode = records.countryCode {
            content.append(.row(title: "Country code", content: countryCode))
        }

        if let emails = records.emails {
            var emailsArr = [String]()
            for email in emails {
                emailsArr.append(email.email ?? "")
            }

            if emailsArr.count > 1 {
                let row = CopyCellType.multiple(title: "Emails", contents: emailsArr.map { .content($0, style: .expandable) })
                content.append(row)
            } else if emailsArr.count == 1 {
                let row = CopyCellType.row(title: "Email", content: emailsArr[0])
                content.append(row)
            }
        }

        if let phones = records.phones {
            var phoneArr = [String]()
            for phone in phones {
                let str = "\(phone.phoneNumber ?? "") \(phone.callHours ?? "")"
                phoneArr.append(str)
            }

            if phoneArr.count > 1 {
                let row = CopyCellType.multiple(title: "Phone Numbers", contents: phoneArr.map { .content($0, style: .expandable) })
                content.append(row)
            } else if phoneArr.count == 1 {
                let row = CopyCellType.row(title: "Phone Number", content: phoneArr[0])
                content.append(row)
            }
        }

        if let domainName = records.domainName {
            content.append(.row(title: "Domain name", content: domainName))
        }

        content.append(.row(title: "Website responed", content: "\(records.websiteResponded ?? false)"))

        var socialRows = [CopyCellType]()

        if let facebook = records.socialLinks?.facebook, !facebook.isEmpty {
            socialRows.append(.row(title: "Facebook", content: facebook, style: .expandable))
        }

        if let twitter = records.socialLinks?.twitter, !twitter.isEmpty {
            socialRows.append(.row(title: "Twitter", content: twitter, style: .expandable))
        }

        if let instagram = records.socialLinks?.instagram, !instagram.isEmpty {
            socialRows.append(.row(title: "Instagram", content: instagram, style: .expandable))
        }

        if let linkedIn = records.socialLinks?.linkedIn, !linkedIn.isEmpty {
            socialRows.append(.row(title: "LinkedIn", content: linkedIn, style: .expandable))
        }

        if !socialRows.isEmpty {
            content.append(.multiple(title: "Social Links", contents: socialRows))
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
      
//        guard let record = response.dnsData.dnsRecords else {
//            throw URLError(URLError.badServerResponse)
//        }
        cache.setObject(response, forKey: host)

        return try configure(with: response)
    }
}
