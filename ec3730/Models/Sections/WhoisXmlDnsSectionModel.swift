import SwiftUI

import SwiftUI

class WhoisXmlDnsSectionModel: HostSectionModel {
    convenience init() {
        self.init(WhoisXml.current, service: WhoisXml.dnsService)
        self.storeModel = StoreKitModel.dns
    }

    func configure(with record: [DNSRecords]?) {
        DispatchQueue.main.async {
            self.content.removeAll()
            
            if let copyData = try? JSONEncoder().encode(record) {
                self.dataToCopy = String(data: copyData, encoding: .utf8)
            }
        }
    }
    
    override func query(url: URL? = nil, completion block: (() -> ())? = nil) {
        guard let host = url?.host else {
            block?()
            return
        }
        
        
        WhoisXml.dnsService.query(["domain": host]) { (error, response: DnsCoordinate?) in
            print(response.debugDescription)

                defer {
                    block?()
                }
                
                guard error == nil else {
                    // todo show error
                    return
                }

                guard let response = response else {
                    // todo show error
                    return
                }

            
                
            self.configure(with: response.dnsData.dnsRecords)
        }
    }
}

