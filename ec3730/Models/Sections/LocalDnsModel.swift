import SwiftUI

class LocalDnsModel: HostSectionModel {
    convenience init() {
        self.init(LocalDns.current, service: LocalDns.lookupService)
    }

    override func configure(with data: Data?) {
        self.dataToCopy = nil
        self.content.removeAll()
        guard let data = data else {
            return
        }
        
        if let addresses = try? JSONDecoder().decode([String].self, from: data) {
            self.configure(addresses: addresses)
        }
    }
    
    func configure(addresses: [String]) {
        self.dataToCopy = nil
        self.content.removeAll()
        
        if let copyData = try? JSONEncoder().encode(addresses) {
            self.dataToCopy = String(data: copyData, encoding: .utf8)
        }
        
        for address in addresses {
            self.content.append(CopyCellView(title: "Address", content: address))
        }
    }
    
    override func query(url: URL? = nil, completion block: (() -> ())? = nil) {
        self.dataToCopy = nil
        self.content.removeAll()
        
        guard let host = url?.host else {
            block?()
            return
        }
        
        self.service.query(["host": host]) { (error, response: [String]?) in
            defer {
                block?()
            }

            guard let addresses = response else {
                return
            }
            
            self.configure(addresses: addresses)
        }
    }
}
