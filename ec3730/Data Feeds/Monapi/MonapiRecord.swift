//
//  MonapiRecord.swift
//  ec3730
//
//  Created by Zachary Gorak on 2/28/20.
//  Copyright © 2020 Zachary Gorak. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
struct MonapiThreat: Codable {
    var error: String?
    var detail: String?
    
    var ip: String?
    var hostname: String?
    var threat_score: Int?
    var threat_class: [String]?
    var threat_level: String?
    var blacklists: [String]?
    var blacklists_list_count: String?
    var is_tor_exit: Bool?
    var is_anonymizer: Bool?
    var is_proxy: Bool?
    var is_malware: Bool?
    var is_attacker: Bool?

    // geolocation
    var city: String?
    var region: String?
    var postal: String?
    var country: String?
    var iso_code: String?
    var longitude: Double?
    var latitude: Double?
    var timezone: String?

    // asn
    var asn_organization: String?
    var asn_number: Int?

    // domain
    var domain: String?
    var blacklist: [String]?
    var mx_blacklist: [[String: String?]]?
    var ns_blacklist: [[String: String?]]?
    var disposable: Bool?

    // email
    /** returns the response message from the mailserver.*/
    var message: String?
    var is_role: Bool?
    var user: String?
    var mail: String?
    /** is true if we find this is an email from a webmailer or freemailer (for example yahoo or gmail). */
    var is_free: Bool?
    /** is true if we connect to the SMTP server successfully. */
    var smtp_server: Bool?
    /** is true if the SMTP server accepts all the email addresses. This could increas the false positive rate */
    var is_catchall: Bool?
    /** is true if we find MX records exist on the domain of the given email address. */
    var mx_records: Bool?
    /** is true if the SMTP server prevented us to perform the STMP check. */
    var block: Bool?
    /** returns the smtp response code from the mailserver. */
    var code: Int?
    var result: String?
    /** is true if we find this is an email address from a disposable email service. */
    var is_disposable: Bool?
    
    enum CodingKeys: String, CodingKey {
        case error, detail
        case ip, hostname, threat_score, threat_class, blacklists, blacklists_list_count, is_anonymizer, is_tor_exit, threat_level, is_proxy, is_malware, is_attacker
        case city, region, postal, country, iso_code, longitude, latitude, timezone
        case asn_organization, asn_number
        case domain, blacklist, mx_blacklist, ns_blacklist, disposable
        case message, is_role, user, mail, is_free, smtp_server, is_catchall, mx_records, block, code, result, is_disposable
    }
    
    init(from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)

        if let _ = try? container.decode(Bool.self, forKey: .mx_blacklist) {
            self.mx_blacklist = [[String:String?]]()
        } else {
            self.mx_blacklist = try? container.decode([[String:String?]]?.self, forKey: .mx_blacklist)
        }
        
        if let _ = try? container.decode(Bool.self, forKey: .blacklist) {
            self.blacklist = [String]()
        } else {
            self.blacklist = try? container.decode([String]?.self, forKey: .blacklist)
        }
        
        if let _ = try? container.decode(Bool.self, forKey: .blacklists) {
            self.blacklists = [String]()
        } else {
            self.blacklists = try? container.decode([String]?.self, forKey: .blacklists)
        }
        
        if let _ = try? container.decode(Bool.self, forKey: .ns_blacklist) {
            self.ns_blacklist = [[String:String?]]()
        } else {
            self.ns_blacklist = try? container.decode([[String:String?]]?.self, forKey: .ns_blacklist)
        }
        
        self.ip = try? container.decode(String?.self, forKey: .ip)
        self.domain = try? container.decode(String?.self, forKey: .domain)
        self.hostname = try? container.decode(String?.self, forKey: .hostname)
        
        self.disposable = try? container.decode(Bool?.self, forKey: .disposable)
        self.is_anonymizer = try? container.decode(Bool?.self, forKey: .is_anonymizer)
        self.is_tor_exit = try? container.decode(Bool?.self, forKey: .is_tor_exit)
        self.is_proxy = try? container.decode(Bool?.self, forKey: .is_proxy)
        self.is_malware = try? container.decode(Bool?.self, forKey: .is_malware)
        self.is_attacker = try? container.decode(Bool?.self, forKey: .is_attacker)
        
        self.threat_score = try? container.decode(Int?.self, forKey: .threat_score)
        self.threat_level = try? container.decode(String?.self, forKey: .threat_level)
        self.threat_class = try? container.decode([String]?.self, forKey: .threat_class)
        
        // asn
        self.asn_organization = try? container.decode(String?.self, forKey: .asn_organization)
        self.asn_number = try? container.decode(Int?.self, forKey: .asn_number)
        
        // geo
        self.iso_code = try? container.decode(String?.self, forKey: .iso_code)
        self.region = try? container.decode(String?.self, forKey: .region)
        self.latitude = try? container.decode(Double?.self, forKey: .latitude)
        self.longitude = try? container.decode(Double?.self, forKey: .longitude)
        self.country = try? container.decode(String?.self, forKey: .country)
        self.city = try? container.decode(String?.self, forKey: .city)
        self.postal = try? container.decode(String?.self, forKey: .postal)
        self.timezone = try? container.decode(String?.self, forKey: .timezone)
        
        // email
        self.is_disposable = try? container.decode(Bool?.self, forKey: .is_disposable)
        self.message = try? container.decode(String?.self, forKey: .message)
        self.is_role = try? container.decode(Bool?.self, forKey: .is_role)
        self.user = try? container.decode(String?.self, forKey: .user)
        self.mail = try? container.decode(String?.self, forKey: .mail)
        self.is_free = try? container.decode(Bool?.self, forKey: .is_free)
        self.smtp_server = try? container.decode(Bool?.self, forKey: .smtp_server)
        self.is_catchall = try? container.decode(Bool?.self, forKey: .is_catchall)
        self.mx_records = try? container.decode(Bool?.self, forKey: .mx_records)
        self.block = try? container.decode(Bool?.self, forKey: .block)
        self.code = try? container.decode(Int?.self, forKey: .code)
        self.result = try? container.decode(String?.self, forKey: .result)

        self.error = try? container.decode(String?.self, forKey: .error)
        self.detail = try? container.decode(String?.self, forKey: .detail)
    }
}
