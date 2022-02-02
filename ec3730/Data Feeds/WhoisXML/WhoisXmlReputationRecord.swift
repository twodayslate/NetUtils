import Foundation

enum WhoisXmlReputationTestCodes: Int, Codable {
    case mailServersReverseIPAddressMatch = 26
    case mailServersRealTimeBlackholeCheck = 32
    case WHOISandDNSnameserversmatch = 61
    case WHOISDomainstatus = 62
    case openportsandservices = 71
    case nameserversconfigurationCheck = 74
    case nameserversresponse = 75
    case nameserversconfigurationmeetsbestpractices = 76
    case mailserversconfigurationCheck = 80
    case mailserversresponse = 81
    case malwaredatabasescheck = 82
    case SOArecordconfigurationCheck = 84
    case SSLcertificatevalidity = 87
    case SSLvulnerabilities = 88
    case Potentiallydangerouscontent = 91
    case Hostconfigurationissues = 92
    case WHOISDomaincheck = 93
    
    func name() -> String{
        switch self {
        case .mailServersReverseIPAddressMatch:
            return "Mail servers Reverse IP addresses match"
        case .mailServersRealTimeBlackholeCheck:
            return "Mail servers Real-time blackhole check"
        case .WHOISandDNSnameserversmatch:
            return "WHOIS and DNS name servers match"
        case .WHOISDomainstatus:
            return "WHOIS Domain status"
        case .openportsandservices:
            return "Open ports and services"
        case .nameserversconfigurationCheck:
            return "Name servers configuration check"
        case .nameserversresponse:
            return "Name servers response"
        case .nameserversconfigurationmeetsbestpractices:
            return "Name servers configuration meets best practices"
        case .mailserversconfigurationCheck:
            return "Mail servers configuration check"
        case .mailserversresponse:
            return "Mail servers response"
        case .malwaredatabasescheck:
            return "Malware databases check"
        case .SOArecordconfigurationCheck:
            return "SOA record configuration check"
        case .SSLcertificatevalidity:
            return "SSL certificate validity"
        case .SSLvulnerabilities:
            return "SSL vulnerabilities"
        case .Potentiallydangerouscontent:
            return "Potentially dangerous content"
        case .Hostconfigurationissues:
            return "Host configuration issues"
        case .WHOISDomaincheck:
            return "WHOIS Domain check"
        }
    }
         
}
enum WhoisXmlReputationWarningCodes: Int, Codable {
    case nameServersWithPrivateIpsFound = 1001
    case Somenameserversdontrespond = 1002
    case Somenameserversallowrecursivequeries = 1003
    case SomenameserversdontprovideArecordfortargetdomainname = 1004
    case Somenameserversarelistedbyauthoritativeserversbutnotbyparentones = 1005
    case Somenameserversarenotlistedbyauthoritativenameservers = 1006
    case Nameserverswithinvaliddomainnamesfound = 1007
    case NSrecordswithCNAMEfound = 1008
    case GlueisrequiredbutnotprovidedNoIPv4IPv6gluefoundonsomeauthoritativeorparentnameservers = 1009
    case NSrecordsaredifferentondifferentnameservers = 1010
    case NameserversnotallowingTCPconnectionstobefound = 1011
    case DomainsnameserversnumberdoesntmeetrecommendationsItsrecommendedtohave27nameservers = 1012
    case SomenameserversarelocatedonasingleASN = 1013
    case Somenameserversarelocatedinthesamenetwork = 1014
    case Versionsareexposedforsomenameservers = 1015
    case NameserverswithoutArecordsfoundThoseserversarenotreachableviaIPv4 = 1016
    case NameserverswithoutAAAArecordfoundThoseserversarenotreachableviaIPv6 = 1017
    case SOAserialnumberisvalidbutnotfollowinggeneralconvention = 1018
    case SOAexpireintervaldoesntmeetrecommendedrangeItshouldbe = 1019
    case SOAminimumTTLdoesntmeetrecommendedrangeItshouldbe = 1020
    case Somenameservershavedifferentserialnumbers = 1022
    case SOArefreshintervaldoesntmeetrecommendedrangeItshouldbe = 1023
    case SOAretryintervaldoesntmeetrecommendedrangeItshouldbe = 1024
    case SOAzonesadministrativecontactemailisnotset = 1025
    case Recentlyregistereddomain = 2001
    case Domainnamesregistrationexpired = 2002
    case Domainnamesregistrationexpiressoon = 2003
    case DomainnamesWHOISstatusisntsafe = 2004
    case Domainnameisregisteredinafreezone = 2005
    case DomainsnameserversnotfoundintheWHOISrecord = 2006
    case WHOISrecordsNameServersdontmatchonesreturnedbytheparentNS = 2007
    case Domainisregisteredinacountryconsideredtobeoffshore = 2008
    case Domainnamesownerdetailsarepubliclyavailable = 2009
    case Directorylistingisallowedonwebsite = 3001
    case IFramesfoundonthewebsite = 3002
    case Linkstoapkfilesfoundonthewebsite = 3003
    case Linkstoexefilesfoundonthewebsite = 3004
    case Openedgitdirectoryinthedocumentrootfound = 3005
    case Thereareopenportsonthetargetserver = 3006
    case Redirectsfoundonwebsite = 3007
    case Scriptsopeningnewwindowsfound = 3008
    case TargetdomainnameorURLlistedonsomeblacklists = 4001
    case SomemailserversdomainnamesreceivedthroughReverseDNSareresolvingtodifferentIPaddressesthantheonesprovidedintheinitialArecordsEmailssentfromserversconfiguredthiswaymayberejected = 5000
    case Somemailserversarefoundwithrealtimeblacklistcheck = 5001
    case Cantconnecttosomemailservers = 5002
    case Forsomemailserversgreetingresponsedoesntcontainthemailserversdomainname = 5003
    case Somemailserversdontallowsettingpostmasterhostasrecipient = 5004
    case Somemailserversdontallowsettingabusehostasrecipient = 5005
    case Arecordsarenotconfiguredforsomemailservers = 5006
    case AAAArecordsarenotconfiguredforsomemailservers = 5007
    case CNAMEinMXrecordsfound = 5008
    case SomeMXrecordscontaininvaliddomainnames = 5009
    case PrivateIPsusageinMXrecordsdetected = 5010
    case IPaddressesfoundinMXrecords = 5011
    case NonidenticalMXrecordsonnameserversfound = 5012
    case SomeMXrecordsdefinedmorethanonce = 5013
    case SomemailserversusethesameIPv4IPv6address = 5014
    case SPFrecordisnotconfigured = 5015
    case DMARCrecordisnotconfigured = 5016
    case NonidenticalSPFDMARCrecordsonnameserversfound = 5017
    case GooglemailserversareconfiguredwithawrongTTL = 5018
    case GooglemailserversareconfiguredwithanincorrectTopserver = 5019
    case NoSSLcertificatesfound = 6023
    case RecentlyobtainedSSLcertificatedetected = 6001
    case SSLcertificateisnotvalidyet = 6002
    case SSLcertificateexpiressoon = 6003
    case SSLcertificateexpired = 6004
    case CRLcheckfailed = 6005
    case OCSPcheckfailed = 6006
    case TargethostnameisntpresentinSSLcertificate = 6007
    case SSLcertificateisselfsigned = 6008
    case TLSv12notsupportedbutshouldbe = 6009
    case SSLv2issupportedbutshouldntbe = 6010
    case SSLv3issupportedbutshouldntbe = 6011
    case Suboptimalciphersuitessupported = 6012
    case SSLcompressionenabledonserver = 6013
    case HPKPheadersset = 6014
    case HTTPStrictTransportSecuritynotset = 6015
    case Heartbleedvulnerabilitydetected = 6017
    case TLS_FALLBACK_SCSVnotsupported = 6018
    case TLSArecordnotset = 6019
    case TLSArecordconfiguredincorrectly = 6020
    case OCSPstaplingnotconfigured = 6021
    case PublickeylistedonDebiansblacklist = 6022
    
    func warning() -> String {
        switch self {

        case .nameServersWithPrivateIpsFound:
            return "Name servers with private IPs found."
        case .Somenameserversdontrespond:
            return "Some name servers don’t respond."
        case .Somenameserversallowrecursivequeries:
            return "Some name servers allow recursive queries."
        case .SomenameserversdontprovideArecordfortargetdomainname:
            return "Some name servers don’t provide A record for target domain name."
        case .Somenameserversarelistedbyauthoritativeserversbutnotbyparentones:
            return "Some name servers are listed by authoritative servers but not by parent ones."
        case .Somenameserversarenotlistedbyauthoritativenameservers:
            return "Some name servers are not listed by authoritative name servers."
        case .Nameserverswithinvaliddomainnamesfound:
            return "Name servers with invalid domain names found."
        case .NSrecordswithCNAMEfound:
            return "NS records with CNAME found."
        case .GlueisrequiredbutnotprovidedNoIPv4IPv6gluefoundonsomeauthoritativeorparentnameservers:
            return "Glue is required but not provided. No IPv4/IPv6 glue found on some authoritative or parent name servers."
        case .NSrecordsaredifferentondifferentnameservers:
            return "NS records are different on different name servers."
        case .NameserversnotallowingTCPconnectionstobefound:
            return "Name servers not allowing TCP connections to be found."
        case .DomainsnameserversnumberdoesntmeetrecommendationsItsrecommendedtohave27nameservers:
            return "Domain’s name servers number doesn’t meet recommendations. It’s recommended to have 2-7 name servers."
        case .SomenameserversarelocatedonasingleASN:
            return "Some name servers are located on a single ASN."
        case .Somenameserversarelocatedinthesamenetwork:
            return "Some name servers are located in the same network."
        case .Versionsareexposedforsomenameservers:
            return "Versions are exposed for some name servers."
        case .NameserverswithoutArecordsfoundThoseserversarenotreachableviaIPv4:
            return "Name servers without A records found. Those servers are not reachable via IPv4."
        case .NameserverswithoutAAAArecordfoundThoseserversarenotreachableviaIPv6:
            return "Name servers without AAAA record found. Those servers are not reachable via IPv6."
        case .SOAserialnumberisvalidbutnotfollowinggeneralconvention:
            return "SOA serial number is valid but not following general convention."
        case .SOAexpireintervaldoesntmeetrecommendedrangeItshouldbe:
            return "SOA expire interval doesn’t meet recommended range. It should be [604800 .. 1209600]."
        case .SOAminimumTTLdoesntmeetrecommendedrangeItshouldbe:
            return "SOA minimum TTL doesn’t meet recommended range. It should be [3600 .. 86400]."
        case .Somenameservershavedifferentserialnumbers:
            return "Some name servers have different serial numbers."
        case .SOArefreshintervaldoesntmeetrecommendedrangeItshouldbe:
            return "SOA refresh interval doesn’t meet recommended range. It should be [1200 .. 43200]."
        case .SOAretryintervaldoesntmeetrecommendedrangeItshouldbe:
            return "SOA retry interval doesn’t meet recommended range. It should be [120 .. 7200]."
        case .SOAzonesadministrativecontactemailisnotset:
            return "SOA zone's administrative contact email is not set."
        case .Recentlyregistereddomain:
            return "Recently registered domain."
        case .Domainnamesregistrationexpired:
            return "Domain name’s registration expired."
        case .Domainnamesregistrationexpiressoon:
            return "Domain name’s registration expires soon."
        case .DomainnamesWHOISstatusisntsafe:
            return "Domain name’s WHOIS status isn’t safe."
        case .Domainnameisregisteredinafreezone:
            return "Domain name is registered in a free zone."
        case .DomainsnameserversnotfoundintheWHOISrecord:
            return "Domain’s name servers not found in the WHOIS record."
        case .WHOISrecordsNameServersdontmatchonesreturnedbytheparentNS:
            return "WHOIS record's Name Servers don't match ones returned by the parent NS."
        case .Domainisregisteredinacountryconsideredtobeoffshore:
            return "Domain is registered in a country considered to be offshore."
        case .Domainnamesownerdetailsarepubliclyavailable:
            return "Domain name’s owner details are publicly available."
        case .Directorylistingisallowedonwebsite:
            return "Directory listing is allowed on website."
        case .IFramesfoundonthewebsite:
            return "IFrames found on the website."
        case .Linkstoapkfilesfoundonthewebsite:
            return "Links to .apk files found on the website."
        case .Linkstoexefilesfoundonthewebsite:
            return "Links to .exe files found on the website."
        case .Openedgitdirectoryinthedocumentrootfound:
            return "Opened .git directory in the document root found."
        case .Thereareopenportsonthetargetserver:
            return "There are open ports on the target server."
        case .Redirectsfoundonwebsite:
            return "Redirects found on website."
        case .Scriptsopeningnewwindowsfound:
            return "Scripts opening new windows found."
        case .TargetdomainnameorURLlistedonsomeblacklists:
            return "Target domain name or URL listed on some blacklists."
        case .SomemailserversdomainnamesreceivedthroughReverseDNSareresolvingtodifferentIPaddressesthantheonesprovidedintheinitialArecordsEmailssentfromserversconfiguredthiswaymayberejected:
            return "Some mail servers' domain names received through Reverse DNS are resolving to different IP addresses than the ones provided in the initial A records. Emails sent from servers configured this way may be rejected."
        case .Somemailserversarefoundwithrealtimeblacklistcheck:
            return "Some mail servers are found with real-time blacklist check."
        case .Cantconnecttosomemailservers:
            return "Can't connect to some mail servers."
        case .Forsomemailserversgreetingresponsedoesntcontainthemailserversdomainname:
            return "For some mail servers, greeting response doesn't contain the mail server's domain name."
        case .Somemailserversdontallowsettingpostmasterhostasrecipient:
            return "Some mail servers don't allow setting postmaster@%host% as recipient."
        case .Somemailserversdontallowsettingabusehostasrecipient:
            return "Some mail servers don't allow setting abuse@%host% as recipient."
        case .Arecordsarenotconfiguredforsomemailservers:
            return "A records are not configured for some mail servers."
        case .AAAArecordsarenotconfiguredforsomemailservers:
            return "AAAA records are not configured for some mail servers."
        case .CNAMEinMXrecordsfound:
            return "CNAME in MX records found."
        case .SomeMXrecordscontaininvaliddomainnames:
            return "Some MX records contain invalid domain names."
        case .PrivateIPsusageinMXrecordsdetected:
            return "Private IPs usage in MX records detected."
        case .IPaddressesfoundinMXrecords:
            return "IP addresses found in MX records."
        case .NonidenticalMXrecordsonnameserversfound:
            return "Non-identical MX records on name servers found."
        case .SomeMXrecordsdefinedmorethanonce:
            return "Some MX records defined more than once."
        case .SomemailserversusethesameIPv4IPv6address:
            return "Some mail servers use the same IPv4/IPv6 address."
        case .SPFrecordisnotconfigured:
            return "SPF record is not configured."
        case .DMARCrecordisnotconfigured:
            return "DMARC record is not configured."
        case .NonidenticalSPFDMARCrecordsonnameserversfound:
            return "Non-identical SPF/DMARC records on name servers found."
        case .GooglemailserversareconfiguredwithawrongTTL:
            return "Google mail servers are configured with a wrong TTL."
        case .GooglemailserversareconfiguredwithanincorrectTopserver:
            return "Google mail servers are configured with an incorrect Top server."
        case .NoSSLcertificatesfound:
            return "No SSL certificates found."
        case .RecentlyobtainedSSLcertificatedetected:
            return "Recently obtained SSL certificate detected."
        case .SSLcertificateisnotvalidyet:
            return "SSL certificate is not valid yet."
        case .SSLcertificateexpiressoon:
            return "SSL certificate expires soon."
        case .SSLcertificateexpired:
            return "SSL certificate expired."
        case .CRLcheckfailed:
            return "CRL check failed."
        case .OCSPcheckfailed:
            return "OCSP check failed."
        case .TargethostnameisntpresentinSSLcertificate:
            return "Target hostname isn’t present in SSL certificate."
        case .SSLcertificateisselfsigned:
            return "SSL certificate is self-signed."
        case .TLSv12notsupportedbutshouldbe:
            return "TLSv1.2 not supported but should be."
        case .SSLv2issupportedbutshouldntbe:
            return "SSLv2 is supported but shouldn’t be."
        case .SSLv3issupportedbutshouldntbe:
            return "SSLv3 is supported but shouldn’t be."
        case .Suboptimalciphersuitessupported:
            return "Suboptimal cipher suites supported."
        case .SSLcompressionenabledonserver:
            return "SSL compression enabled on server."
        case .HPKPheadersset:
            return "HPKP headers set."
        case .HTTPStrictTransportSecuritynotset:
            return "HTTP Strict Transport Security not set."
        case .Heartbleedvulnerabilitydetected:
            return "Heartbleed vulnerability detected."
        case .TLS_FALLBACK_SCSVnotsupported:
            return "TLS_FALLBACK_SCSV not supported."
        case .TLSArecordnotset:
            return "TLSA record not set."
        case .TLSArecordconfiguredincorrectly:
            return "TLSA record configured incorrectly."
        case .OCSPstaplingnotconfigured:
            return "OCSP stapling not configured."
        case .PublickeylistedonDebiansblacklist:
            return "Public key listed on Debian’s blacklist."
        }
    }
}

struct WhoisXmlReputationRecord: Codable {
    var mode: String?
    var reputationScore: Double?
    var testResults: [WhoisXmlReputationTestResult]?
}

struct WhoisXmlReputationTestResult: Codable {
    var test: String
    var testCode: Int
    var warnings: [String]
    var warningCodes: [Int]
}
